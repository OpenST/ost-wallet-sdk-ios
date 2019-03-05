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
    let workflowTransactionCountForPolling = 2
    
    var spendingLimit: String
    var expireAfter: TimeInterval
    
    var salt: String? = nil
    var recoveryAddress: String? = nil
    var sessionHelper: OstSessionHelper.SessionHelper? = nil
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - pin: User pin.
    ///   - password: Password provied by application server.
    ///   - spendingLimit: Maximum spending limit of transaction.
    ///   - expireAfter: Relative time.
    ///   - delegate: Callback.
    init(userId: String, pin: String, password: String, spendingLimit: String, expireAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter
        
        super.init(userId: userId, delegate: delegate)
        
        self.uPin = pin
        self.appUserPassword = password
    }
    
    /// Get workflow thread.
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowThread() -> DispatchQueue {
        return self.ostActivateUserThread
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        if (self.currentUser!.isStatusActivating) {
            self.pollingForActivatingUser(self.currentUser!)
            return
        }
        
        self.salt = try self.getSalt()
        
        self.recoveryAddress = self.getRecoveryKey()
        if (nil == self.recoveryAddress) {
            throw OstError.init("w_p_p_4", .recoveryAddressNotFound)
        }
        
        self.sessionHelper = try OstSessionHelper(userId: self.userId,
                                                  expiresAfter: self.expireAfter,
                                                  spendingLimit: self.spendingLimit).getSessionData()
        try self.activateUser()
        
    }
    override func validateParams() throws {
        try super.validateParams()
        
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
        
        if  OstSessionHelper.SESSION_BUFFER_TIME > self.expireAfter {
            throw OstError.init("w_au_vp_4",
                                "Expiration height should be greater than \(OstSessionHelper.SESSION_BUFFER_TIME)")
        }
        
        if (self.currentUser == nil) {
            throw OstError.init("w_au_vp_5", .userEntityNotFound)
        }
        if (self.currentUser!.isStatusActivated) {
            throw OstError("w_au_vp_6", .userAlreadyActivated)
        }
        
        if (self.currentDevice == nil) {
            throw OstError.init("w_au_vp_7", .deviceNotFound)
        }
        
        if (!self.currentDevice!.isStatusRegistered &&
            (self.currentDevice!.isStatusRevoking ||
                self.currentDevice!.isStatusRevoked )) {
            throw OstError("w_au_vp_8", "Device is revoked for \(self.userId). Plese setup device first by calling OstSdk.setupDevice")
        }
        
        if (self.currentDevice!.isStatusAuthorized) {
            throw OstError("w_au_vp_9", OstErrorText.deviceAuthorized)
        }
    }
    
    //TODO: integrate it with AddSessionFlow. Code duplicate.
    func getRecoveryKey() -> String? {
        do {
            return try OstCryptoImpls().generateRecoveryKey(password: self.appUserPassword,
                                                            pin: self.uPin,
                                                            userId: self.userId,
                                                            salt: self.salt!,
                                                            n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
                                                            r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
                                                            p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
                                                            size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES)
        }catch {
            return nil
        }
    }
    
    //    func generateAndSaveSessionEntity() throws {
    //        let params = self.getSessionEnityParams()
    //        try OstSession.storeEntity(params)
    //
    //    }
    //
    //    func getSessionEnityParams() -> [String: Any] {
    //        var params: [String: Any] = [:]
    //        params["user_id"] = self.userId
    //        params["address"] = self.sessionHelper!.sessionAddress
    //        params["expiration_height"] = self.sessionHelper!.expirationHeight
    //        params["spending_limit"] = self.spendingLimit
    //        params["nonce"] = 0
    //        params["status"] = OstSession.Status.CREATED.rawValue
    //
    //        return params
    //    }
    
    func activateUser() throws {
        let params = self.getActivateUserParams()
        var ostError: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIUser(userId: self.userId).activateUser(params: params, onSuccess: { (ostUser) in
            self.currentUser = ostUser
            group.leave()
        }) { (error) in
            ostError = error
            group.leave()
        }
        group.wait()
        
        if (nil == ostError) {
            self.postRequestAcknowledged(entity: self.currentUser!)
            self.pollingForActivatingUser(self.currentUser!)
        }else {
            throw ostError!
        }
    }
    
    func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_owner_address"] = self.recoveryAddress!
        params["expiration_height"] = self.sessionHelper!.expirationHeight//self.expirationHeight + self.currentBlockHeight
        params["session_addresses"] = [self.sessionHelper!.sessionAddress]
        params["device_address"] = self.currentUser!.getCurrentDevice()!.address!
        
        return params
    }
    
    func pollingForActivatingUser(_ ostUser: OstUser) {
        
        let successCallback: ((OstUser) -> Void) = { ostUser in
            self.currentUser = ostUser
            self.syncRespctiveEntity()
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        _ = OstUserPollingService(userId: ostUser.id, workflowTransactionCount: workflowTransactionCountForPolling, successCallback: successCallback, failureCallback: failureCallback).perform()
    }
    
    
    func syncRespctiveEntity() {
        if (self.sessionHelper?.sessionAddress != nil) {
            try? OstAPISession(userId: self.userId).getSession(sessionAddress: self.sessionHelper!.sessionAddress, onSuccess: nil, onFailure: nil)
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
