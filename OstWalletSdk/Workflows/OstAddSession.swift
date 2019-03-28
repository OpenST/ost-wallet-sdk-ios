/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddSession: OstWorkflowBase {
    
    static private let ostAddSessionQueue = DispatchQueue(label: "com.ost.sdk.OstAddSession", qos: .userInitiated)
    private let spendingLimit: String
    private let expireAfter: TimeInterval;
    
    private var sessionData: OstSessionHelper.SessionData? = nil
  
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
        do {
            try self.workFlowValidator!.isValidNumber(input: self.spendingLimit)
        }catch {
            throw OstError("w_as_vp_1", .invalidSpendingLimit)
        }
        
        if (TimeInterval(0) > self.expireAfter) {
            throw OstError("w_as_vp_2", .invalidExpirationTimeStamp)
        }
        
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
        
        let onRequestAcknowledged: ((OstSession) -> Void) = { (ostSession) in
            self.postRequestAcknowledged(entity: ostSession)
        }

        let onSuccess: ((OstSession) -> Void) = { (ostSession) in            self.postWorkflowComplete(entity: ostSession)
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            self.postError(error)
        }
        
        OstAuthorizeSession(userId: self.userId,
                            sessionAddress: self.sessionData!.sessionAddress,
                            spendingLimit: self.spendingLimit,
                            expirationHeight: self.sessionData!.expirationHeight,
                            generateSignatureCallback: generateSignatureCallback,
                            onRequestAcknowledged: onRequestAcknowledged,
                            onSuccess: onSuccess,
                            onFailure: onFailure).perform()
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
