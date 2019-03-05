//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstActivateUser: OstWorkflowBase {
    let ostActivateUserQueue = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    let workflowTransactionCountForPolling = 2
    
    var spendingLimit: String
    var expireAfter: TimeInterval
    
    var recoveryAddress: String? = nil
    var sessionHelper: OstSessionHelper.SessionHelper? = nil
    private var pinManager: OstPinManager? = nil
    
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
        
        self.pinManager = OstPinManager(userId: self.userId, password: password, pin: pin)
    }

    /// Get workflow queue.
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostActivateUserQueue
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        if (self.currentUser!.isStatusActivating) {
            self.pollingForActivatingUser(self.currentUser!)
            return
        }
        
        self.recoveryAddress = self.pinManager?.getRecoveryOwnerAddress()
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
        
        try self.pinManager!.validatePinLength()
        try self.pinManager!.validatePasswordLength()
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > self.userId.count {
            throw OstError.init("w_au_vp_2",
                                "Pin postfix should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
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
