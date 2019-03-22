/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstLogoutPollingService: OstBasePollingService {
    
    static private let logoutPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstLogoutPollingService", qos: .background)
    private let successCallback: ((OstTokenHolder) -> Void)?
    init(userId: String,
         successStatus: String,
         failureStatus: String,
         workflowTransactionCount: Int,
         successCallback: ((OstTokenHolder) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.successCallback = successCallback
        
        super.init(userId: userId,
                   successStatus: successStatus,
                   failureStatus: failureStatus,
                   workflowTransactionCount: 1,
                   failureCallback: failureCallback)
    }
    
    /// Fetch entity from server
    ///
    /// - Throws: OstError
    override func fetchEntity() throws {
        try OstAPITokenHolder(userId: self.userId)
            .getTokenHolder(onSuccess: onSuccess,
                            onFailure: onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: Recovery owner entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstTokenHolder)
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return OstLogoutPollingService.logoutPollingServiceDispatchQueue
    }
    
}
