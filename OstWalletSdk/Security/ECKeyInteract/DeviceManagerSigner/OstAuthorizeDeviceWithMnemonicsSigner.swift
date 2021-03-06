/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeDeviceWithMnemonicsSigner: OstDeviceManagerSignerBase {
    private let abiMethodNameForAuthorizeDevice = "addOwnerWithThreshold"
    private let threshold = 1

    private let mnemonicsManager: OstMnemonicsKeyManager
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddressToAdd: Device address to add
    ///   - mnemonicsManager: OstMnemonicsKeyManager
    ///   - keyManagerDelegate: OstKeyManagerDelegate
    init (userId: String,
          deviceAddressToAdd: String,
          mnemonicsManager: OstMnemonicsKeyManager,
          keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.mnemonicsManager = mnemonicsManager
        super.init(userId: userId,
                   address: deviceAddressToAdd,
                   keyManagerDelegate: keyManagerDelegate)        
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe()
            .getAddOwnerWithThresholdExecutableData(ownerAddress: self.address,
                                                    threshold: OstUtils.toString(self.threshold)!)
        return encodedABIHex
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getToAddress() -> String? {
        return self.deviceManager!.address!
    }
    
    /// Get raw calldata
    ///
    /// - Returns: raw calldata JSON string
    override func getRawCallData() -> String {
        let callData: [String : Any] = ["method": self.abiMethodNameForAuthorizeDevice,
                                        "parameters": [self.address,
                                                       self.threshold]]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// Generate signature
    ///
    /// - Returns: Signature, SignerAddress
    override func generateSignature(_ signingHash: String) -> (String?, String?) {
        
        if let signature = try? self.keyManagerDelegate
            .signWithExternalDevice(signingHash,
                                    withMnemonics: self.mnemonicsManager.mnemonics) {
            
            return (signature, self.mnemonicsManager.address)
        }
        
        return (nil, nil)
    }
}
