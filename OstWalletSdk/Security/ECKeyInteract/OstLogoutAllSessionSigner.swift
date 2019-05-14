/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstLogoutAllSessionSigner {
    private let nullAddress = "0x0000000000000000000000000000000000000000"
    private let abiMethodNameForLogout = "logout"
    private let userId: String
    private let keyManagerDelegate: OstKeyManagerDelegate
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - keyManagerDelegate: OstKeyManagerDelegate
    init(userId: String,
         keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.keyManagerDelegate = keyManagerDelegate
    }
    
    /// Get Api parameters for logout all sessions
    ///
    /// - Returns: Api parameters
    /// - Throws: OstError
    func getApiParams() throws -> [String: Any] {
    
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("s_ecki_lass_gap_1", .userNotFound)
        }
        guard let deviceManager: OstDeviceManager = try OstDeviceManager.getById(user.deviceManagerAddress!) else {
            throw OstError("s_ecki_lass_gap_2", .deviceManagerNotFound)
        }
        
        let encodedABIHex = try TokenHolder().getLogoutExecutableData()
        
        let deviceManagerNonce: Int = deviceManager.nonce
        
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: deviceManager.address!,
                                                                           to: user.tokenHolderAddress!,
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
        
        let signingHash = try! eip712.getEIP712Hash()
        
        let signature = try self.keyManagerDelegate.signWithDeviceKey(signingHash)
        let signer = self.keyManagerDelegate.getDeviceAddress()
        
        let rawCallData: String = getRawCallData()
        
        let params: [String: Any] = ["to": user.tokenHolderAddress!,
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
                                     "signers": [signer],
                                     "signatures": signature
        ]
        
        try deviceManager.incrementNonce()
        return params
    }
    
    /// Get raw call data for logout
    ///
    /// - Returns: Raw calldata JSON string
    private func getRawCallData() -> String {
        let callData: [String: Any] = ["method": self.abiMethodNameForLogout,
                                       "parameters":[]]
        return try! OstUtils.toJSONString(callData)!
    }
}
