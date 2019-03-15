/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstActivateUser: OstWorkflowBase {
    static private let ostActivateUserQueue = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    private let workflowTransactionCountForPolling = 2
    private let spendingLimit: String
    private var expireAfter: TimeInterval
    private var recoveryAddress: String? = nil
    private var sessionData: OstSessionHelper.SessionData? = nil
    private var pinManager: OstPinManager? = nil
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Passphrase prefix provied by application server.
    ///   - spendingLimit: Maximum spending limit of transaction.
    ///   - expireAfter: Relative time.
    ///   - delegate: Callback.
    init(userId: String,
         userPin: String,
         passphrasePrefix: String,
         spendingLimit: String,
         expireAfter: TimeInterval,
         delegate: OstWorkFlowCallbackDelegate) {
        
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter
        
        super.init(userId: userId, delegate: delegate)
        
        self.pinManager = OstPinManager(userId: self.userId,
                                        passphrasePrefix: passphrasePrefix,
                                        userPin: userPin)
    }
    
    /// Get workflow queue.
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstActivateUser.ostActivateUserQueue
    }
    
    /// Validate params for activate user
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        try self.workFlowValidator!.isValidNumber(input: self.spendingLimit)
        try self.pinManager!.validatePinLength()
        try self.pinManager!.validatePassphrasePrefixLength()
        
        if (self.currentUser?.isStatusActivated)! {
            throw OstError("w_au_vp_1", .userAlreadyActivated)
        }
        if (self.currentDevice?.isStatusAuthorized)! {
            throw OstError("w_au_vp_2", .deviceAlreadyAuthorized)
        }
        
        if  0 > self.expireAfter {
            throw OstError.init("w_au_vp_3",
                                "Expiration time should be greater than 0")
        }
        
        if (!self.currentDevice!.isStatusRegistered &&
            (self.currentDevice!.isStatusRevoking ||
                self.currentDevice!.isStatusRevoked )) {
            throw OstError("w_au_vp_4", "Device is revoked for \(self.userId). Please setup device first by calling OstSdk.setupDevice")
        }
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
            throw OstError.init("w_au_p_1", .recoveryAddressNotFound)
        }
        
        self.sessionData = try OstSessionHelper(
                userId: self.userId,
                expiresAfter: self.expireAfter,
                spendingLimit: self.spendingLimit
            ).getSessionData()
        
        try self.activateUser()
    }
    
    
    /// Activate user
    ///
    /// - Throws: OstError
    private func activateUser() throws {
        let params = self.getActivateUserParams()
        var ostError: OstError? = nil
        let group = DispatchGroup()
        var userEntity: OstUser? = nil
        group.enter()
        try OstAPIUser(userId: self.userId).activateUser(params: params, onSuccess: { (ostUser) in
            userEntity = ostUser
            group.leave()
        }) { (error) in
            ostError = error
            group.leave()
        }
        group.wait()
        
        if (nil == ostError) {
            self.postRequestAcknowledged(entity: userEntity!)
            self.pollingForActivatingUser(userEntity!)
        }else {
            throw ostError!
        }
    }
    
    /// Get params for activate user
    ///
    /// - Returns: Activate user params dictionary
    private func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_owner_address"] = self.recoveryAddress!
        params["expiration_height"] = self.sessionData!.expirationHeight
        params["session_addresses"] = [self.sessionData!.sessionAddress]
        params["device_address"] = self.currentDevice!.address!
        
        return params
    }
    
    /// Poll for activate user
    ///
    /// - Parameter ostUser: User entity
    private func pollingForActivatingUser(_ ostUser: OstUser) {
        
        let successCallback: ((OstUser) -> Void) = { ostUser in
            self.sync()
        }
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstUserPollingService(userId: ostUser.id,
                              successStatus: OstUser.Status.ACTIVATED.rawValue,
                              failureStatus: OstUser.Status.CREATED.rawValue,
                              workflowTransactionCount: workflowTransactionCountForPolling,
                              successCallback: successCallback,
                              failureCallback: failureCallback
            ).perform()
    }
    
    
    /// Sync entities that were updated in activate user process
    private func sync() {
        if (self.sessionData?.sessionAddress != nil) {
            try? OstAPISession(userId: self.userId)
                .getSession(
                    sessionAddress: self.sessionData!.sessionAddress,
                    onSuccess: nil,
                    onFailure: nil
                )
        }
        
        try? OstAPIDeviceManager(userId: self.userId)
            .getDeviceManager(
                onSuccess: nil,
                onFailure: nil
            )

        OstSdkSync(
            userId: self.userId,
            forceSync: true,
            syncEntites: .CurrentDevice,
            onCompletion: { (_) in
                self.postWorkflowComplete(entity: self.currentUser!)
            }
        ).perform()
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
