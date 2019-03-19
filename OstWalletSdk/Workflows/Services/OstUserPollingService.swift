/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import CryptoSwift

class OstUserPollingService: OstBasePollingService {
    
    let userPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstUserPollingService", qos: .background)
    let successCallback: ((OstUser) -> Void)?
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - workflowTransactionCount: workflow transaction count
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         successStatus: String,
         failureStatus: String,
         workflowTransactionCount: Int,
         successCallback: ((OstUser) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
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
         try OstAPIUser.init(userId: self.userId).getUser(onSuccess: self.onSuccess, onFailure: self.onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: User entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstUser)
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return self.userPollingServiceDispatchQueue
    }
}
