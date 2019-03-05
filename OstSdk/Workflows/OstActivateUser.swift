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
    var expireAfter: TimeInterval
    
    var recoveryAddress: String? = nil
    var sessionHelper: OstSessionHelper.SessionHelper? = nil
    
    let workflowTransactionCountForPolling = 2
    
    private var pinManager: OstPinManager? = nil
    
    init(userId: String, pin: String, password: String, spendingLimit: String, expireAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter
        
        super.init(userId: userId, delegate: delegate)
        
        self.pinManager = OstPinManager(userId: self.userId, password: password, pin: pin)
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
                
                self.recoveryAddress = self.pinManager!.getRecoveryOwnerAddress()
                
                if (self.recoveryAddress == nil) {
                    self.postError(OstError.init("w_p_p_4", .recoveryAddressNotFound))
                    return
                }
                
                OstSessionHelper(userId: self.userId, expiresAfter: self.expireAfter)
                    .getSessionData(onSuccess: { (sessionHelper) in
                        self.sessionHelper = sessionHelper
                        do {
                            try self.generateAndSaveSessionEntity()
                            self.activateUser()
                        }catch let error {
                            self.postError(error)
                        }
                    }, onFailure: { (error) in
                        self.postError(error)
                    })
                
            }catch let error{
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        try self.pinManager!.validatePinLength()
        try self.pinManager!.validatePasswordLength()
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > self.userId.count {
            throw OstError.init("w_au_vp_2",
                                "Pin postfix should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        
        let minExpirationTime = Date().timeIntervalSince1970 + OstSessionHelper.SESSION_BUFFER_TIME
        if minExpirationTime > self.expireAfter {
            throw OstError.init("w_au_vp_5",
                                "Expiration height should be greater than \(minExpirationTime)")
        }
    }
    
    //TODO: integrate it with AddSessionFlow. Code duplicate.
    
    
    func generateAndSaveSessionEntity() throws {
        let params = self.getSessionEnityParams()
        try OstSession.storeEntity(params)
        
    }
    
    func getSessionEnityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.sessionHelper!.sessionAddress
        params["expiration_height"] = self.sessionHelper!.expirationHeight
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
