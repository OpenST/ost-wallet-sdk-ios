//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

let API_SCRYPT_SALT_KEY = "scrypt_salt"

class OstActivateUser: OstWorkflowBase {
    let ostActivateUserThread = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    
    var spendingLimit: String
    var expirationHeight: Int
    
    var salt: String = "salt"
    var sessionAddress: String? = nil
    var recoveryAddress: String? = nil
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
                
                self.currentUser = try self.getUser()
                if (self.currentUser == nil) {
                    self.postError(OstError.init("w_p_p_1", .userEntityNotFound))
                    return
                }
            
                if (self.currentUser!.isStatusActivated) {
                self.postError(OstError("w_au_p_1", .userAlreadyActivated) )
                    return
                }
                
                if (self.currentUser!.isStatusActivating) {
                    self.pollingForActivatingUser(self.currentUser!)
                    return
                }
                
                self.currentDevice = self.currentUser!.getCurrentDevice()
                if (self.currentDevice == nil) {
                    throw OstError.init("w_p_p_2", "Device is not present for \(self.userId). Plese setup device first by calling OstSdk.setupDevice")
                }

                if (!self.currentDevice!.isStatusRegistered &&
                    (self.currentDevice!.isStatusRevoking ||
                    self.currentDevice!.isStatusRevoked )) {
                    throw OstError("w_p_p_3", "Device is revoked for \(self.userId). Plese setup device first by calling OstSdk.setupDevice")
                }
                
                if (self.currentDevice!.isStatusAuthorized) {
                    throw OstError("w_p_p_4", OstErrorText.deviceAuthorized)
                }

                let onCompletion: (() -> Void) = {
                    self.recoveryAddress = self.getRecoveryKey()

                    if (self.recoveryAddress == nil) {
                        self.postError(OstError.init("w_p_p_4", .recoveryAddressNotFound))
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
            throw OstError.init("w_au_vp_1",
                                "Pin prefix must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > self.userId.count {
            throw OstError.init("w_au_vp_2",
                                "Pin postfix should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.uPin.count {
            throw OstError.init("w_au_vp_3",
                                "Pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        if OstConstants.OST_MIN_EXPIRATION_BLOCK_HEIGHT > self.expirationHeight {
            throw OstError.init("w_au_vp_5",
                                "Expiration height should be greater than \(OstConstants.OST_MIN_EXPIRATION_BLOCK_HEIGHT)")
        }
    }
    
    func getSalt(onCompletion: @escaping (() -> Void)) throws {
        try OstAPISalt(userId: self.userId).getRecoverykeySalt(onSuccess: { (saltResponse) in
            self.salt = saltResponse[API_SCRYPT_SALT_KEY] as! String
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
    //TODO: - merge code with add session
    func generateSessionKeys() {
        do {
            let keyMananger = OstKeyManager(userId: self.userId)
            self.sessionAddress = try keyMananger.createSessionKey()
        }catch let error {
            self.postError(error)
        }
    }
    //TODO: - merge code with add session
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
    //TODO: - merge code with add session
    func generateAndSaveSessionEntity() {
        do {
            let params = self.getSessionEnityParams()
            try OstSession.storeEntity(params)
        }catch let error {
            self.postError(error)
        }
    }
    //TODO: - Get expirationHeight from timestamp and block_formation time
    func getSessionEnityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.sessionAddress!
        params["expiration_height"] = self.currentBlockHeight + self.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.Status.CREATED.rawValue
        
        return params
    }
    
    func activateUser() {
        do {
            let params = self.getActivateUserParams()
            
            try OstAPIUser(userId: self.userId).activateUser(params: params, onSuccess: { (ostUser) in
                self.postRequestAcknowledged(entity: ostUser)
                self.pollingForActivatingUser(ostUser)
            }) { (error) in
                self.postError(error)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_owner_address"] = self.recoveryAddress!
        params["expiration_height"] = self.expirationHeight + self.currentBlockHeight
        params["session_addresses"] = [self.sessionAddress!]
        params["device_address"] = self.currentUser!.getCurrentDevice()!.address!
        
        return params
    }
    
    func pollingForActivatingUser(_ ostUser: OstUser) {
        
        let successCallback: ((OstUser) -> Void) = { ostUser in
            self.currentUser = ostUser
            self.syncRespctiveEntity()
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        _ = OstUserPollingService(userId: ostUser.id, workflowTransactionCount: workflowTransactionCountForPolling, successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }
    
    
    func syncRespctiveEntity() {
        if (self.sessionAddress != nil) {
            try? OstAPISession(userId: self.userId).getSession(sessionAddress: self.sessionAddress!, onSuccess: nil, onFailure: nil)
        }
        try? OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: nil, onFailure: nil)
        OstSdkSync(userId: self.userId, forceSync: true, syncEntites: .CurrentDevice, onCompletion: { (_) in
            self.currentDevice = self.currentUser!.getCurrentDevice()
            self.postWorkflowComplete(entity: self.currentUser!)
        }).perform()
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
