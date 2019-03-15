//
//  OstTransactionPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 26/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTransactionPollingService: OstBasePollingService {
    static  let transactionPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstTransactionPollingService", qos: .background)
    let successCallback: ((OstTransaction) -> Void)?
    let transaciotnId: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - transaciotnId: Transaction id to poll
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - workflowTransactionCount: workflow transaction count
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         transaciotnId: String,
         successStatus: String,
         failureStatus: String,
         workflowTransactionCount: Int,
         successCallback: ((OstTransaction) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.successCallback = successCallback
        self.transaciotnId = transaciotnId
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
        try OstAPITransaction(userId: userId).getTransaction(transcionId: self.transaciotnId,
                                                             onSuccess: self.onSuccess,
                                                             onFailure: self.onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: Transaction entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstTransaction)
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return OstTransactionPollingService.transactionPollingServiceDispatchQueue
    }
}
