/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRevokeDevice: OstRevokeBase {
    private let abiMethodNameForRevokeDevice = "removeOwner"
    private let threshold = 1
    private let workflowTransactionCountForPolling = 1
    
    private let linkedAddress: String
    private let onRequestAcknowledged: ((OstDevice)-> Void)
    private let onSuccess: ((OstDevice)-> Void)
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - linkedAddress: Linked address of device
    ///   - deviceAddressToRevoke: Device address to revoke
    ///   - generateSignatureCallback: Callback to get signature
    ///   - onRequestAcknowledged: Callback for request acknowledge
    ///   - onSuccess: Callback when flow successfull
    ///   - onFailure: Callback when flow failed
    init (userId: String,
          linkedAddress: String,
          deviceAddressToRevoke: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onRequestAcknowledged: @escaping ((OstDevice) -> Void),
          onSuccess: @escaping ((OstDevice) -> Void),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.linkedAddress = linkedAddress
        self.onSuccess = onSuccess
        self.onRequestAcknowledged = onRequestAcknowledged
        super.init(userId: userId,
                   addressToRevoke: deviceAddressToRevoke,
                   generateSignatureCallback: generateSignatureCallback,
                   onFailure: onFailure)
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe()
            .getRevokeDeviceWithThresholdExecutableData(prevOwner: self.linkedAddress,
                                                        owner: self.addressToRevoke,
                                                        threshold: OstUtils.toString(self.threshold)!)
        return encodedABIHex
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getToAddress() -> String? {
        return self.deviceManager?.address
    }
    
    /// Get raw calldata
    ///
    /// - Returns: raw calldata JSON string
    override func getRawCallData() -> String {
        let callData:[String : Any] = ["method": self.abiMethodNameForRevokeDevice,
                                       "parameters": [self.linkedAddress,
                                                      self.addressToRevoke,
                                                      self.threshold]
                                      ]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// API request for authorize device
    ///
    /// - Parameter params: API parameters for authorize device
    /// - Throws: OstError
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        var ostError: OstError? = nil
        var revokeDevice: OstDevice? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: self.userId).revokeDevice(params: params, onSuccess: { (ostDevice) in
            revokeDevice = ostDevice
            group.leave()
        }) { (error) in
            ostError = error
            group.leave()
        }
        group.wait()
        if (nil != ostError) {
            try? self.fetchDeviceManager()
            throw ostError!
        }
        
        self.onRequestAcknowledged(revokeDevice!)
        self.pollingForRevokeDevice()
    }
    
    /// Polling for device
    func pollingForRevokeDevice() {
        
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.onSuccess(ostDevice)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                try? self.fetchDeviceManager()
                self.onFailure(error)
            }
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.addressToRevoke,
                                workflowTransactionCount: self.workflowTransactionCountForPolling,
                                successStatus: OstDevice.Status.REVOKED.rawValue,
                                failureStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
    }
}
