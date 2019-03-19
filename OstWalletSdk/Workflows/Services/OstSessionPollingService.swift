/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstSessionPollingService: OstBasePollingService {
    let sessionPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstSessionPollingService", qos: .background)
    let successCallback: ((OstSession) -> Void)?
    let sessionAddress: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - sessionAddress: Session address to poll
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - workflowTransactionCount: workflow transaction count
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         sessionAddress: String,
         successStatus: String,
         failureStatus: String,
         workflowTransactionCount: Int,
         successCallback: ((OstSession) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.sessionAddress = sessionAddress
        self.successCallback = successCallback
        super.init(userId: userId,
                   successStatus: successStatus,
                   failureStatus: failureStatus,
                   workflowTransactionCount: workflowTransactionCount,
                   failureCallback: failureCallback)
    }

    /// Fetch entity from server
    ///
    /// - Throws: OstError
    override func fetchEntity() throws {
        try OstAPISession(userId: self.userId)
            .getSession(
                sessionAddress: sessionAddress,
                onSuccess: self.onSuccess,
                onFailure: onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: Session entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstSession)
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return self.sessionPollingServiceDispatchQueue
    }
}
