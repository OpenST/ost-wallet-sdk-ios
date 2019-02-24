//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstActivateUser: OstWorkflowBase {
    let ostActivateUserThread = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    
    var spendingLimit: String
    var expirationHeight: Int
    
    var salt: String = "salt"
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    var walletKeys: OstWalletKeys? = nil
    var recoveryAddreass: String? = nil
    var currentBlockHeight: Int = 0
    
    let workflowTransactionCountForPolling = 2
    
    init(userId: String, pin: String, password: String, spendingLimit: String, expirationHeight: Int, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        super.init(userId: userId, delegate: delegate)
        
        self.uPin = pin
        self.appUserPassword = password
    }
    
    override func perform() {
        ostActivateUserThread.async {
            do {
                try self.validateParams()
                
                self.user = try self.getUser()
                if (self.user == nil) {
                    self.postError(OstError.actionFailed("User is not present for \(self.userId)."))
                    return
                }
            
                if (self.user!.isActivated()) {
                self.postError(OstError1("w_au_p_1", .userAlreadyActivated) )
                    return
                }
                
                if (self.user!.isActivating()) {
                    self.pollingForActivatingUser(self.user!)
                    return
                }
                
                self.currentDevice = self.user!.getCurrentDevice()
                if (self.currentDevice == nil) {
                    self.postError(OstError.actionFailed("Device is not present for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }

                if (self.currentDevice!.isDeviceRevoked()) {
                    self.postError(OstError.actionFailed("Device is revoked for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }

                if (!self.currentDevice!.isDeviceRegistered()) {
                    self.postError(OstError.actionFailed("Device is registed for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }

                let onCompletion: (() -> Void) = {
                    self.recoveryAddreass = self.getRecoveryKey()

                    if (self.recoveryAddreass == nil) {
                        self.postError(OstError.actionFailed("recovery address formation failed."))
                        return
                    }

                    self.generateSessionKeys()
                    self.getCurrentBlockHeight()
                }

                try self.getSalt(onCompletion: onCompletion)
                
            }catch let error{
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.appUserPassword.count {
            throw OstError.invalidInput("pinPrefix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > self.userId.count {
            throw OstError.invalidInput("pinPostfix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.uPin.count {
            throw OstError.invalidInput("pin should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        if OstConstants.OST_MIN_EXPIRATION_BLOCK_HEIGHT > self.expirationHeight {
            throw OstError.invalidInput("Expiration height should be greater than \(OstConstants.OST_MIN_EXPIRATION_BLOCK_HEIGHT)")
        }
    }
    
    func getSalt(onCompletion: @escaping (() -> Void)) throws {
        try OstAPISalt(userId: self.userId).getRecoverykeySalt(onSuccess: { (saltResponse) in
            self.salt = saltResponse["scrypt_salt"] as! String
            onCompletion()
        }, onFailure: { (error) in
            self.postError(error)
        })
    }
    //TODO: integrate it with AddSessionFlow. Code duplicate.
    func getRecoveryKey() -> String? {
        do {
            return try OstCryptoImpls().generateRecoveryKey(password: self.appUserPassword,
                                                            pin: self.uPin,
                                                            userId: self.userId,
                                                            salt: salt,
                                                            n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
                                                            r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
                                                            p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
                                                            size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES)
        }catch {
            return nil
        }
    }
    
    func generateSessionKeys() {
        do {
            self.walletKeys = try OstCryptoImpls().generateOstWalletKeys()
            
            if (self.walletKeys == nil || self.walletKeys!.privateKey == nil || self.walletKeys!.address == nil) {
                self.postError(OstError.actionFailed("activation of user failed."))
            }
            
            let sessionKeyInfo: OstSessionKeyInfo = try currentDevice!.encrypt(privateKey: walletKeys!.privateKey!)
            
            var ostSecureKey = OstSecureKey(address: walletKeys!.address!, privateKeyData: sessionKeyInfo.sessionKeyData, isSecureEnclaveEnrypted: sessionKeyInfo.isSecureEnclaveEncrypted)
            ostSecureKey = OstSecureKeyRepository.sharedSecureKey.insertOrUpdateEntity(ostSecureKey) as! OstSecureKey
        }catch let error {
            self.postError(error)
        }
    }
    
    func getCurrentBlockHeight() {
        do {
            let onSuccess: (([String: Any]) -> Void) = { chainInfo in
                self.currentBlockHeight = OstUtils.toInt(chainInfo["block_height"])!
                self.generateAndSaveSessionEntity()
                self.activateUser()
            }
            
            let onFailuar: ((OstError) -> Void) = { error in
                self.postError(error)
            }
            
            _ = try OstAPIChain(userId: self.userId).getChain(onSuccess: onSuccess, onFailure: onFailuar)
        }catch let error {
            self.postError(error)
        }
    }
    
    func generateAndSaveSessionEntity() {
        do {
            let params = self.getSessionEnityParams()
            _ = try OstSession.parse(params)
        }catch let error {
            self.postError(error)
        }
    }
    //TODO: Get expirationHeight from timestamp and block_formation time
    func getSessionEnityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.walletKeys!.address!
        params["expiration_height"] = self.currentBlockHeight + self.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.SESSION_STATUS_CREATED
        
        return params
    }
    
    func activateUser() {
        do {
            let params = self.getActivateUserParams()
            
            try OstAPIUser(userId: self.userId).activateUser(params: params, onSuccess: { (ostUser) in
                self.pollingForActivatingUser(ostUser)
            }) { (error) in
                self.postError(error)
                //******************************************                self.pollingForActivatingUser(self.user!)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_owner_address"] = self.recoveryAddreass!
        params["expiration_height"] = self.expirationHeight + self.currentBlockHeight
        params["session_addresses"] = [self.walletKeys!.address!]
        params["device_address"] = user!.getCurrentDevice()!.address!
        
        return params
    }
    
    func pollingForActivatingUser(_ ostUser: OstUser) {
        
        let successCallback: ((OstUser) -> Void) = { ostUser in
            self.syncRespctiveEntity()
            self.postWorkflowComplete(entity: ostUser)
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        _ = OstUserPollingService(userId: ostUser.id, workflowTransactionCount: workflowTransactionCountForPolling, successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }
    
    
    func syncRespctiveEntity() {
     
            _ = try? OstAPISession(userId: self.userId).getSession(sessionAddress: walletKeys!.address!, onSuccess: nil, onFailure: nil)
            _ = try? OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: nil, onFailure: nil)
            _ = OstSdkSync(userId: self.userId, forceSync: true, syncEntites: .CurrentDevice, onCompletion: nil)
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .activateUser)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .user)
    }
}