//
//  OstAuthorizeDevice.swift
//  
//
//  Created by aniket ayachit on 21/02/19.
//

import Foundation

class OstAuthorizeDevice: OstAuthorizeBase {
    let abiMethodNameForAuthorizeDevice = "addOwnerWithThreshold"
    
    let onSuccess: ((OstDevice)-> Void)
    init (userId: String,
          deviceAddressToAdd: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onSuccess: @escaping ((OstDevice)-> Void),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.onSuccess = onSuccess
        
        super.init(userId: userId,
                   addressToAdd: deviceAddressToAdd,
                   generateSignatureCallback: generateSignatureCallback,
                   onFailure: onFailure)
    }
    
    
    override func perform() {
        do {
            try self.getDevice()
        }catch let error {
            self.onFailure(error as! OstError)
        }
    }
    
    func getDevice() throws {
        let onSuccess: ((OstDevice) -> Void) = { ostDevice in
            if (ostDevice.isDeviceRegistered()) {
                do {
                    try self.fetchDeviceManager()
                }catch let error{
                    self.onFailure(error as! OstError)
                }
            }else {
                self.onFailure(OstError.actionFailed("Device is not registered."))
            }
        }
        
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: self.addressToAdd, onSuccess: onSuccess) { (ostError) in
            self.onFailure(ostError)
        }
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
    
    override func getRawCallData() -> [String: Any] {
        return ["method": self.abiMethodNameForAuthorizeDevice,
                "parameters": [addressToAdd, "1"]]
    }
    
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        try OstAPIDevice(userId: self.userId).authorizeDevice(params: params, onSuccess: { (ostDevice) in
            self.onSuccess(ostDevice)
        }) { (error) in
            self.onFailure(error)
        }
    }
}
