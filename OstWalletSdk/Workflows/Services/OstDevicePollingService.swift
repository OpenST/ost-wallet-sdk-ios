/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDevicePollingService: OstBasePollingService {
    static private let devicePollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstDevicePollingService", qos: .background)
    
    private let successStatus: String
    private let failureStatus: String
    private let successCallback: ((OstDevice) -> Void)?
    private let deviceAddress: String
    private let workflowTransactionCountForPolling = 1
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddress: Device address to poll
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         deviceAddress: String,
         successStatus: String,
         failureStatus: String,
         successCallback: ((OstDevice) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.successStatus = successStatus
        self.failureStatus = failureStatus
        self.successCallback = successCallback
        self.deviceAddress = deviceAddress
        super.init(userId: userId,
                   successStatus: successStatus,
                   failureStatus: failureStatus,
                   workflowTransactionCount: workflowTransactionCountForPolling,
                   failureCallback: failureCallback)
    }
    
    /// Fetch entity
    ///
    /// - Throws: OstError
    override func fetchEntity() throws {
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: self.deviceAddress, onSuccess: self.onSuccess, onFailure: self.onFailure)
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: Device entity
    override func postSuccessCallback(entity: OstBaseEntity) {
        self.successCallback?(entity as! OstDevice)
    }
    
    /// Get queue for polling
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return OstDevicePollingService.devicePollingServiceDispatchQueue
    }
}
