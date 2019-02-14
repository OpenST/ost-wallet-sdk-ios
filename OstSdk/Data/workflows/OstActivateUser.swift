//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstActivateUser: OstWorkflowBase, OstPinAcceptProtocol, OstDeviceRegisteredProtocol {
    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    
    var pin: String
    var pinPrefix: String
    var spendingLimit: String
    var expirationHeight: String
    
    var salt: String = "salt"
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    var walletKeys: OstWalletKeys? = nil
    var recoveryAddreass: String? = nil
    
    init(userId: String, pin: String, password: String, spendingLimit: String, expirationHeight: String, delegate: OstWorkFlowCallbackProtocol) {
        self.pin = pin
        self.pinPrefix = password
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostRegisterDeviceThread.sync {
            do {
                try self.validateParams()
                
                user = try getUser()
                if (user == nil) {
                    self.postError(OstError.actionFailed("User is not present for \(self.userId)."))
                }
                
                if (user!.status == nil || user!.isCreated()) {
                    self.postError(OstError.actionFailed("User is created \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }
                
                if (user!.isActivated()) {
                    self.postFlowComplete(entity: user!)
                    return
                }
                
                if (user!.isActivating()) {
                    self.pollingForActivatingUser(user!)
                    return
                }
                
                currentDevice = user!.getCurrentDevice()
                if (currentDevice == nil) {
                    self.postError(OstError.actionFailed("Device is not present for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }
                
                if (currentDevice!.isDeviceRevoked()) {
                    self.postError(OstError.actionFailed("Device is revoked for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                    return
                }
                
                if (currentDevice!.isDeviceRegistered()) {
                    self.pollingForActivatingUser(user!)
                    return
                }
                
                let onCompletion: (() -> Void) = {
                    self.recoveryAddreass = self.getRecoveryKey()
                    
                    if (self.recoveryAddreass == nil) {
                        self.postError(OstError.actionFailed("recovery address formation failed."))
                        return
                    }
                    
                    self.generateSessionKeys()
                    self.generateAndSaveSessionEntity()
                    self.activateUser()
                }
                
                try getSalt(onCompletion: onCompletion)
                
            }catch let error{
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.pinPrefix.count {
            throw OstError.invalidInput("pinPrefix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > self.userId.count {
            throw OstError.invalidInput("pinPostfix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.pin.count {
            throw OstError.invalidInput("pin should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
    }
    
    func getSalt(onCompletion: @escaping (() -> Void)) throws {
        try OstAPISalt(userId: self.userId).getRecoverykeySalt(success: { (saltResponse) in
            self.salt = saltResponse["scrypt_salt"] as! String
            onCompletion()
        }, failuar: { (error) in
            onCompletion()
            //            self.postError(error)
        })
    }
    
    func getRecoveryKey() -> String? {
        do {
            return try OstCryptoImpls().generateRecoveryKey(pinPrefix: self.pinPrefix, pin: self.pin, pinPostFix: self.userId, salt: salt, n: OstConstants.OST_SCRYPT_N, r: OstConstants.OST_SCRYPT_R, p: OstConstants.OST_SCRYPT_P, size: OstConstants.OST_SCRYPT_DESIRED_SIZE_BYTES)
        }catch {
            return nil
        }
    }
    
    func generateSessionKeys() {
        do {
            self.walletKeys = try OstCryptoImpls().generateCryptoKeys()
            
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
    
    func generateAndSaveSessionEntity() {
        do {
            let params = self.getSessionEnityParams()
            _ = try OstSession.parse(params)
        }catch let error {
            self.postError(error)
        }
        
    }
    
    func getSessionEnityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.walletKeys!.address!
        params["expiration_height"] = self.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.SESSION_STATUS_INITITIALIZING
        
        return params
    }
    
    func activateUser() {
        do {
            let params = self.getActivateUserParams()
            
            try OstAPIUser(userId: self.userId).activateUser(params: params, success: { (ostUser) in
                self.pollingForActivatingUser(ostUser)
            }) { (error) in
//                self.postError(error)
                self.pollingForActivatingUser(self.user!)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_address"] = self.recoveryAddreass!
        params["expiration_height"] = self.expirationHeight
        params["session_addresses"] = [self.walletKeys!.address!]
        
        return params
    }
    
    func pollingForActivatingUser(_ ostUser: OstUser) {
        
        let successCallback: ((OstUser) -> Void) = { ostUser in
            self.syncRespctiveEntity()
            self.postFlowComplete(entity: ostUser)
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        
        _ = OstUserPollingService(userId: ostUser.id, successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }
    
    
    func syncRespctiveEntity() {
        do {
            _ = try OstAPISession(userId: self.userId).getSession(sessionAddress: walletKeys!.address!, success: nil, failuar: nil)
            _ = try OstAPIDeviceManager(userId: self.userId).getDeviceManager(success: nil, failuar: nil)
        }catch {
            
        }
    }
    
    func postFlowComplete(entity: OstUser) {
        Logger.log(message: "OstActivateUser flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .activateUser , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
    
    //MARK: - OstPinAcceptProtocol
    public func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
}
