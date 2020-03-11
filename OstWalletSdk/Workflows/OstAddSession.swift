/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddSession: OstUserAuthenticatorWorkflow {
    
    static private let ostAddSessionQueue = DispatchQueue(label: "com.ost.sdk.OstAddSession", qos: .userInitiated)
    private let workflowTransactionCountForPolling = 1
    private let spendingLimit: String
    private var expireAfter: TimeInterval;
    
    var sessionData: OstSessionHelper.SessionData? = nil
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - spendingLimit: Spending limit for transaction
    ///   - expireAfter: Relative time
    ///   - delegate: Callback
    init(userId: String,
         spendingLimit: String,
         expireAfter: TimeInterval,
         delegate: OstWorkflowDelegate) {
        
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter;
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstAddSession.ostAddSessionQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()        
        if ( !isValidNumber(input: self.spendingLimit) ) {
            throw OstError("w_as_vp_1", .invalidSpendingLimit)
        }
        
        if (TimeInterval(0) > self.expireAfter) {
            throw OstError("w_as_vp_2", .invalidExpirationTimeStamp)
        }
    }
    
    /// Proceed with workflow after user is authenticated.
    override func onUserAuthenticated() throws {
        _ = try syncDeviceManager()
        self.sessionData = try OstSessionHelper(userId: self.userId,
                                                expiresAfter: self.expireAfter,
                                                spendingLimit: self.spendingLimit).getSessionData()
        try self.authorizeSession()
    }
    
    /// Authorize session
    func authorizeSession() throws {
        
        let authorizeSessionSigner = OstKeyManagerGateway
            .getOstAuthorizeSessionSigner(userId: self.userId,
                                          sessionAddress: self.sessionData!.sessionAddress,
                                          spendingLimit: self.spendingLimit,
                                          expirationHeight: self.sessionData!.expirationHeight)
        
        let authroizeSessionParams = try authorizeSessionSigner.getApiParams()
        
        try OstAPISession(userId: self.userId)
            .authorizeSession(params: authroizeSessionParams,
                              onSuccess: { (ostSession) in
                                
                                self.postRequestAcknowledged(entity: ostSession)
                                self.pollingForAuthorizeSession(ostSession)
                                
            }, onFailure: { (error) in
                self.postError(error)
            })
    }
    
    
    /// Polling service for Session
    ///
    /// - Parameter ostSession: session entity
    private func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.postWorkflowComplete(entity: ostSession)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                self.postError(error)
            }
        }
        
        OstSessionPollingService(userId: ostSession.userId!,
                                 sessionAddress: ostSession.address!,
                                 successStatus: OstSession.Status.AUTHORIZED.rawValue,
                                 failureStatus: OstSession.Status.CREATED.rawValue,
                                 workflowTransactionCount: self.workflowTransactionCountForPolling,
                                 successCallback: successCallback,
                                 failureCallback: failureCallback).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .addSession)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .session)
    }
}
