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
    
//    /// Process Entity after success from API
//    ///
//    /// - Parameter entity: User entity
//    override func onSuccessProcess(entity: OstBaseEntity) {
//        let ostUser: OstUser = entity as! OstUser
//        if (ostUser.isStatusActivating) {
//            // Logger.log(message: "test User status is activating for userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
//            self.getEntityAfterDelay()
//        }else if (ostUser.isStatusActivated) {
//            self.successCallback?(ostUser)
//        }else{
//            // Logger.log(message: "test User with userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
//            self.onFailure?(OstError("w_s_dps_osp_1", OstErrorText.failedToProcess) )
//        }
//    }
//
//

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
