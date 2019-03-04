//
//  OstAuthorizeDevice.swift
//  
//
//  Created by aniket ayachit on 21/02/19.
//

import Foundation

class OstAuthorizeDevice: OstAuthorizeBase {
    let abiMethodNameForAuthorizeDevice = "addOwnerWithThreshold"
    
    let onRequestAcknowledged: ((OstDevice)-> Void)
    let onSuccess: ((OstDevice)-> Void)
    
    init (userId: String,
          deviceAddressToAdd: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onRequestAcknowledged: @escaping ((OstDevice) -> Void),
          onSuccess: @escaping ((OstDevice) -> Void),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.onSuccess = onSuccess
        self.onRequestAcknowledged = onRequestAcknowledged
        super.init(userId: userId,
                   addressToAdd: deviceAddressToAdd,
                   generateSignatureCallback: generateSignatureCallback,
                   onFailure: onFailure)
    }
    
    class func getDevice(userId: String, addressToAdd: String, onSuccess: @escaping ((OstDevice) -> Void), onFailure: @escaping ((OstError) -> Void)) throws {
        let onSuccess: ((OstDevice) -> Void) = { ostDevice in
            if (ostDevice.isStatusRegistered) {
                onSuccess(ostDevice)
            }else {
                onFailure(OstError("w_a_ad_gd_1", .deviceNotRegistered))
            }
        }
        
        try OstAPIDevice(userId: userId).getDevice(deviceAddress: addressToAdd,
                                                   onSuccess: onSuccess,
                                                   onFailure: onFailure)
    }
    
  
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe().getAddOwnerWithThresholdExecutableData(abiMethodName: self.abiMethodNameForAuthorizeDevice,
                                                                                    ownerAddress: self.addressToAdd,
                                                                                    threshold: OstUtils.toString(self.threshold)!)
        return encodedABIHex
    }
    
    override func getToForTypedData() -> String? {
        return self.deviceManager?.address
    }
    
    override func getRawCallData() -> String {
        let callData = ["method": self.abiMethodNameForAuthorizeDevice,
                        "parameters": [addressToAdd, "1"]] as [String : Any]
        return try! OstUtils.toJSONString(callData)!
    }
    
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        try OstAPIDevice(userId: self.userId).authorizeDevice(params: params, onSuccess: { (ostDevice) in
            self.onRequestAcknowledged(ostDevice)
            self.pollingForAddDevice()
        }) { (error) in
            self.onFailure(error)
        }
    }

    func pollingForAddDevice() {
        
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.onSuccess(ostDevice)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.onFailure(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.addressToAdd,
                                workflowTransactionCount: self.workflowTransactionCountForPolling,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
    }
}
