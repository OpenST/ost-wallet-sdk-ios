/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRevokeDeviceSigner: OstDeviceManagerSignerBase {
    private let abiMethodNameForRevokeDevice = "removeOwner"
    private let threshold = 1
    private let linkedAddress: String
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - linkedAddress: Linked address of device
    ///   - deviceAddressToRevoke: Device address to revoke
    init (userId: String,
          linkedAddress: String,
          deviceAddressToRevoke: String,
          keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.linkedAddress = linkedAddress
        super.init(userId: userId,
                   address: deviceAddressToRevoke,
                   keyManagerDelegate: keyManagerDelegate)
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe()
            .getRevokeDeviceWithThresholdExecutableData(prevOwner: self.linkedAddress,
                                                        owner: self.address,
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
                                                      self.address,
                                                      self.threshold]
        ]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// Generate signature
    ///
    /// - Returns: Signature, SignerAddress
    override func generateSignature(_ signingHash: String) -> (String?, String?) {
        if let deviceAddress = self.keyManagerDelegate.getDeviceAddress(),
            let signature = try? self.keyManagerDelegate.signWithDeviceKey(signingHash) {
            return (signature, deviceAddress)
        }
        return (nil, nil)
    }
    
}
