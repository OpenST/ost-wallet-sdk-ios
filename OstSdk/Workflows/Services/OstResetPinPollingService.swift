/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstResetPinPollingService: OstBasePollingService {
    static private let resetPinPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstResetPinPollingService", qos: .background)
    private let successCallback: ((OstRecoveryOwnerEntity) -> Void)?
    private let recoveryOwnerAddress: String

    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - recoveryOwnerAddress: recovery owner address
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - workflowTransactionCount: workflow transaction count
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         recoveryOwnerAddress: String,
         successStatus: String,
         failureStatus: String,
         workflowTransactionCount: Int,
         successCallback: ((OstRecoveryOwnerEntity) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.recoveryOwnerAddress = recoveryOwnerAddress
        self.successCallback = successCallback
        
        super.init(userId: userId,
                   successStatus: successStatus,
                   failureStatus: failureStatus,
                   workflowTransactionCount: workflowTransactionCount,
                   failureCallback: failureCallback
        )
    }
    
    /// Fetch entity from server
    ///
    /// - Throws: OstError
    override func fetchEntity() throws {
        try OstAPIResetPin(userId: self.userId)
            .getRecoverOwner(
                recoveryOwnerAddress: self.recoveryOwnerAddress,
                onSuccess: self.onSuccess,
                onFailure: self.onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: Recovery owner entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstRecoveryOwnerEntity)
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return OstResetPinPollingService.resetPinPollingServiceDispatchQueue
    }
}
