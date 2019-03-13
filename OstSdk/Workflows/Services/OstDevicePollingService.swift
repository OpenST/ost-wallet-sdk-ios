//
//  OstDevicePollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDevicePollingService: OstBasePollingService {
    static private let devicePollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstDevicePollingService", qos: .background)
    
    private let successStatus: String
    private let failureStatus: String
    private let successCallback: ((OstDevice) -> Void)?
    private let deviceAddress: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddress: Device address to poll
    ///   - workflowTransactionCount: workflow transaction count
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - successCallback: Success callback
    ///   - failureCallback: Failure callback
    init(userId: String,
         deviceAddress: String,
         workflowTransactionCount: Int,
         successStatus: String,
         failureStatus: String,
         successCallback: ((OstDevice) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.successStatus = successStatus
        self.failureStatus = failureStatus
        self.successCallback = successCallback
        self.deviceAddress = deviceAddress
        super.init(userId: userId, workflowTransactionCount: workflowTransactionCount, failureCallback: failureCallback)
    }

    /// Process entity after getting success callback from server
    ///
    /// - Parameter entity: Device entity
    override func onSuccessProcess(entity: OstBaseEntity) {
        let ostDevice: OstDevice = entity as! OstDevice
        if (ostDevice.status!.caseInsensitiveCompare(self.successStatus) == .orderedSame) {
            // Logger.log(message: "test User with userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.successCallback?(ostDevice)
            
        }else if (ostDevice.status!.caseInsensitiveCompare(self.failureStatus) == .orderedSame){
            self.onFailure?(OstError("w_s_dps_osp_1", OstErrorText.failedToProcess) )
        }else{
            // Logger.log(message: "test User status is activating for userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.getEntityAfterDelay()
        }
    }
    
    /// Fetch entity
    ///
    /// - Throws: OstError
    override func fetchEntity() throws {
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: self.deviceAddress, onSuccess: self.onSuccess, onFailure: self.onFailure)
    }
    
    /// Get queue for polling
    ///
    /// - Returns: DispatchQueue
    override func getPollingQueue() -> DispatchQueue {
        return OstDevicePollingService.devicePollingServiceDispatchQueue
    }
}
