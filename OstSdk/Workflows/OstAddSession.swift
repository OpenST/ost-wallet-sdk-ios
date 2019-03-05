//
//  OstAddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 19/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAddSession: OstWorkflowBase {
    
    let ostAddSessionQueue = DispatchQueue(label: "com.ost.sdk.OstAddSession", qos: .background)
    let workflowTransactionCountForPolling = 1
    
    var spendingLimit: String
    var expireAfter: TimeInterval;
    
    var sessionHelper: OstSessionHelper.SessionHelper? = nil
  
    init(userId: String, spendingLimit: String, expireAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter;
        super.init(userId: userId, delegate: delegate)
    }
    
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostAddSessionQueue
    }
    
    override func process() throws {
        self.sessionHelper = try OstSessionHelper(userId: self.userId,
                                                  expiresAfter: self.expireAfter,
                                                  spendingLimit: self.spendingLimit).getSessionData()
        self.authorizeSession()
    }
    
    override func validateParams() throws {
        if (nil == self.currentUser) {
            throw OstError("w_as_vp_1", .userNotFound)
        }
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_as_vp_1", .userNotActivated)
        }
        
        if (nil == self.currentDevice) {
            throw OstError("w_as_vp_2", .deviceNotFound);
        }
        if (!self.currentDevice!.isStatusAuthorized) {
            throw OstError("w_as_vp_3", .deviceNotAuthorized)
        }
    }
    
    func authorizeSession() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                if let deviceAddress = keychainManager.getDeviceAddress() {
                    let signature = try keychainManager.signWithDeviceKey(signingHash)
                    return (signature, deviceAddress)
                }
                throw OstError("w_as_as_1", .signatureGenerationFailed)
            }catch {
                return (nil, nil)
            }
        }
        
        let onSuccess: ((OstSession) -> Void) = { (ostSession) in
            self.postRequestAcknowledged(entity: ostSession)
            self.pollingForAuthorizeSession(ostSession)
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            Logger.log(message: "I am here - OstAddSession");
            self.postError(error)
        }
        
        OstAuthorizeSession(userId: self.userId,
                            sessionAddress: self.sessionHelper!.sessionAddress,
                            spendingLimit: self.spendingLimit,
                            expirationHeight: self.sessionHelper!.expirationHeight,
                            generateSignatureCallback: generateSignatureCallback,
                            onSuccess: onSuccess,
                            onFailure: onFailure).perform()
    }
    
    func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.postWorkflowComplete(entity: ostSession)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstSessionPollingService(userId: ostSession.userId!,
                                 sessionAddress: ostSession.address!,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .addSession)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .session)
    }
}
