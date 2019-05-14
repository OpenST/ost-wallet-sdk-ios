/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDeviceManagerSignerBase {
    private let ostDeviceManagerSignerBase = DispatchQueue(label: "OstDeviceManagerSignerBase", qos: .background)
    private let nullAddress = "0x0000000000000000000000000000000000000000"
    
    let userId: String
    let address: String
    let keyManagerDelegate: OstKeyManagerDelegate
    
    var deviceManager: OstDeviceManager? = nil
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - address: Address
    ///   - keyManagerDelegate: OstKeyManagerDelegate.
    init (userId: String,
          address: String,
          keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.address = address
        self.keyManagerDelegate = keyManagerDelegate
    }
    
    
    /// Get Api parameters
    ///
    /// - Returns: Api parameters
    /// - Throws: OstError
    func getApiParams() throws -> [String: Any] {
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("s_ecki_dms_dmsb_gap_1", .userNotFound)
        }
        self.deviceManager = try OstDeviceManager.getById(user.deviceManagerAddress!)
        if nil == self.deviceManager{
            throw OstError("s_ecki_dms_dmsb_gap_2", .deviceManagerNotFound)
        }
        
        let deviceManagerNonce: Int = self.deviceManager!.nonce
        
        let encodedABIHex = try getEncodedABI()
        
        guard let toAddress = getToAddress() else {
            throw OstError("w_a_ab_a_1", .toAddressNotFound)
        }
        
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                           to: toAddress,
                                                                           value: "0",
                                                                           data: encodedABIHex,
                                                                           operation: "0",
                                                                           safeTxGas: "0",
                                                                           dataGas: "0",
                                                                           gasPrice: "0",
                                                                           gasToken: self.nullAddress,
                                                                           refundReceiver: self.nullAddress,
                                                                           nonce: OstUtils.toString(deviceManagerNonce)!)
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any],
                                    primaryType: typedDataInput["primaryType"] as! String,
                                    domain: typedDataInput["domain"] as! [String: String],
                                    message: typedDataInput["message"] as! [String: Any])
        
        let signingHash = try eip712.getEIP712Hash()
        
        let (signature, signerAddress) = generateSignature(signingHash)
        
        if (nil == signature
            || signature!.isEmpty) {
            throw OstError("q_a_ab_a_2", .signatureGenerationFailed)
        }
        
        if (nil == signerAddress
            || signerAddress!.isEmpty) {
            throw OstError("q_a_ab_a_2", .signerAddressNotFound)
        }
        
        let rawCallData: String = getRawCallData()
        
        let params: [String: Any] = ["to": toAddress,
                                     "value": "0",
                                     "calldata": encodedABIHex,
                                     "raw_calldata": rawCallData,
                                     "operation": "0",
                                     "safe_tx_gas": "0",
                                     "data_gas": "0",
                                     "gas_price": "0",
                                     "nonce": OstUtils.toString(deviceManagerNonce)!,
                                     "gas_token": self.nullAddress,
                                     "refund_receiver": self.nullAddress,
                                     "signers": [signerAddress],
                                     "signatures": signature!
        ]
        try self.deviceManager!.incrementNonce()
        
        return params
    }
    
    //MARK: - Methods to override
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    func getEncodedABI() throws -> String {
        fatalError("getEncodedABI is not override.")
    }
    
    /// Get raw calldata
    ///
    /// - Returns: raw calldata JSON string
    func getRawCallData() -> String {
        fatalError("getRawCallData is not override.")
    }
    
    /// To address
    ///
    /// - Returns: to address for authorize
    func getToAddress() -> String? {
        fatalError("getToForTypeData is not override.")
    }
    
    /// Generate signature
    ///
    /// - Returns: Signature, SignerAddress
    func generateSignature(_ signingHash: String) -> (String?, String?) {
        fatalError("generateSignature is not override.")
    }
}
