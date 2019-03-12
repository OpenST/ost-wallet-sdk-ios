//
//  OstAuthorizeDevice.swift
//  
//
//  Created by aniket ayachit on 21/02/19.
//

import Foundation

class OstAuthorizeDevice: OstAuthorizeBase {
    private let abiMethodNameForAuthorizeDevice = "addOwnerWithThreshold"
    private let threshold = 1
    private let workflowTransactionCountForPolling = 1
    
    private let onRequestAcknowledged: ((OstDevice)-> Void)
    private let onSuccess: ((OstDevice)-> Void)
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddressToAdd: Device address to add
    ///   - generateSignatureCallback: Callback to get signature
    ///   - onRequestAcknowledged: Callback for request acknowledge
    ///   - onSuccess: Callback when flow successfull
    ///   - onFailure: Callback when flow failed
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
   
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe()
            .getAddOwnerWithThresholdExecutableData(ownerAddress: self.addressToAdd,
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
        let callData = ["method": self.abiMethodNameForAuthorizeDevice,
                        "parameters": [self.addressToAdd, self.threshold]] as [String : Any]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// API request for authorize device
    ///
    /// - Parameter params: API parameters for authorize device
    /// - Throws: OstError
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        var ostError: OstError? = nil
        var authorizeDevice: OstDevice? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: self.userId).authorizeDevice(params: params, onSuccess: { (ostDevice) in
            authorizeDevice = ostDevice
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
       
        self.onRequestAcknowledged(authorizeDevice!)
        self.pollingForAddDevice()
    }

    /// Polling for device
    func pollingForAddDevice() {
        
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.onSuccess(ostDevice)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                try? self.fetchDeviceManager()
                self.onFailure(error)
            }
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.addressToAdd,
                                workflowTransactionCount: self.workflowTransactionCountForPolling,
                                successStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                failureStatus: OstDevice.Status.REGISTERED.rawValue,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
    }
}
