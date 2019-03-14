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
    
//    /// Process Entity after success from API
//    ///
//    /// - Parameter entity: User entity
//    override func onSuccessProcess(entity: OstBaseEntity) {
//        let ostTransaction: OstTransaction = entity as! OstTransaction
//        if (ostTransaction.isStatusSuccess) {
//            // Logger.log(message: "test User with userId: \(ostTransaction.id) and is success at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
//            self.successCallback?(ostTransaction)
//        }else if (ostTransaction.isStatusFailed){
//            // Logger.log(message: "test User with userId: \(ostTransaction.id) and is failed at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
//            self.failureCallback?(OstError("w_s_tos_osp_1", OstErrorText.transactionFailed))
//        }else {
//            // Logger.log(message: "test User status is activating for userId: \(ostTransaction.id) and is activated at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
//            self.getEntityAfterDelay()
//        }
//    }
    
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
