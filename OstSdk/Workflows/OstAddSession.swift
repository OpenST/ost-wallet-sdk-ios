//
//  OstAddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 19/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAddSession: OstWorkflowBase {
    
    private let ostAddSessionQueue = DispatchQueue(label: "com.ost.sdk.OstAddSession", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let spendingLimit: String
    private let expireAfter: TimeInterval;
    
    private var sessionData: OstSessionHelper.SessionData? = nil
  
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - spendingLimit: Spending limit for transaction in Wei
    ///   - expireAfter: Relative time
    ///   - delegate: Callback
    init(userId: String,
         spendingLimit: String,
         expireAfter: TimeInterval,
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter;
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostAddSessionQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceAuthorized()
    }
    
    /// process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
        authenticateUser()
    }
    
    /// Proceed with workflow after user is authenticated.
    override func proceedWorkflowAfterAuthenticateUser() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            do {
                self.sessionData = try OstSessionHelper(userId: self.userId,
                                                        expiresAfter: self.expireAfter,
                                                        spendingLimit: self.spendingLimit).getSessionData()
                self.authorizeSession()
            }catch let error {
                self.postError(error)
            }
            
        }
    }

    /// Authorize session
    private func authorizeSession() {
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
            self.postError(error)
        }
        
        OstAuthorizeSession(userId: self.userId,
                            sessionAddress: self.sessionData!.sessionAddress,
                            spendingLimit: self.spendingLimit,
                            expirationHeight: self.sessionData!.expirationHeight,
                            generateSignatureCallback: generateSignatureCallback,
                            onSuccess: onSuccess,
                            onFailure: onFailure).perform()
    }
    
    /// Polling service for Session
    ///
    /// - Parameter ostSession: session entity
    private func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
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
