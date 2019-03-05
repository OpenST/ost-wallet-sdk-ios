//
//  OstDevicePollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDevicePollingService: OstBasePollingService {
    let devicePollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstDevicePollingService", qos: .background)
    
    let successCallback: ((OstDevice) -> Void)?
    let deviceAddress: String
    init(userId: String, deviceAddress: String, workflowTransactionCount: Int, successCallback: ((OstDevice) -> Void)?, failureCallback: ((OstError) -> Void)?) {
        
        self.successCallback = successCallback
        self.deviceAddress = deviceAddress
        super.init(userId: userId, workflowTransactionCount: workflowTransactionCount, failureCallback: failureCallback)
    }
    
    override func onSuccessProcess(entity: OstBaseEntity) {
        let ostDevice: OstDevice = entity as! OstDevice
        if (ostDevice.isStatusAuthorizing) {
            Logger.log(message: "test User status is activating for userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.getEntityAfterDelay()
        }else{
            Logger.log(message: "test User with userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.successCallback?(ostDevice)
        }
    }
    
    override func fetchEntity() throws {
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: self.deviceAddress, onSuccess: self.onSuccess, onFailure: self.onFailure)
    }
    
    override func getPollingQueue() -> DispatchQueue {
        return self.devicePollingServiceDispatchQueue
    }
}
