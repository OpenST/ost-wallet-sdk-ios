//
//  OstUserPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 13/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
