/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstLogoutAllSessions: OstWorkflowEngine {
    static private let ostLogoutAllSessionsQueue = DispatchQueue(label: "com.ost.sdk.OstLogoutAllSessions", qos: .background)
    private let workflowTransactionCount = 1
//    private let nullAddress = "0x0000000000000000000000000000000000000000"
//    private let abiMethodNameForLogout = "logout"
    
//    private var deviceManager: OstDeviceManager? = nil
//    private var signature: String? = nil
//    private var signer: String? = nil
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstLogoutAllSessions.ostLogoutAllSessionsQueue
    }
    
    /// Validate user and device
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()        
        try isUserActivated()
    }
    
    /// Check for current device authorization
    ///
    /// - Returns: `true` if check required, else `false`
    override func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return false
    }

    /// Logout all sessions after device validated.
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        try syncDeviceManager()
        
        let logoutAllSessionsSigner = OstKeyManagerGateway.getOstLogoutAllSessionSigner(userId: self.userId)
        let logoutParams = try logoutAllSessionsSigner.getApiParams()
        
        try logoutAllSessions(params: logoutParams)
    }
    
    /// Logout all sessions
    ///
    /// - Parameter params: Logout request parameters
    /// - Throws: OstError
    private func logoutAllSessions(params: [String: Any]) throws {
        var err: OstError? = nil
        var tokenHolder: OstTokenHolder? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPITokenHolder(userId: self.userId)
            .logout(params: params,
                    onSuccess: { (ostTokenHolder) in
                        tokenHolder = ostTokenHolder
                        group.leave()
            }, onFailure: { (error) in
                err = error
                group.leave()
            })
        group.wait()
        if (nil != err) {
            _ = try? fetchDeviceManager()
            throw err!
        }
        self.postRequestAcknowledged(entity: tokenHolder!)
        OstKeyManagerGateway
            .getOstKeyManager(userId: self.userId)
            .deleteAllSessions()
        
        pollingForLogoutAllSessions(entity: tokenHolder!)
    }
    
    /// Polling for token holders
    ///
    /// - Parameter tokenHolder: TokenHolder entity
    private func pollingForLogoutAllSessions(entity: OstTokenHolder) {
        let successCallback: ((OstTokenHolder) -> Void) = { ostTokenHolder in
            self.postWorkflowComplete(entity: ostTokenHolder)
        }
        
        let failureCallback: ((OstError) -> Void) = { error in
            self.postError(error)
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
    
        OstLogoutPollingService(userId: self.userId,
                                successStatus: OstTokenHolder.Status.LOGGED_OUT.rawValue,
                                failureStatus: OstTokenHolder.Status.ACTIVE.rawValue,
                                workflowTransactionCount: self.workflowTransactionCount,
                                successCallback:successCallback,
                                failureCallback: failureCallback).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .logoutAllSessions)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .tokenHolder)
    }
}
