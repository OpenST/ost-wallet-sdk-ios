/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class GnosisSafe: ABIHelperBase {
    
    private let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
    private let ABI_NAME = "GnosisSafe.abi"
    
    private let ADD_OWNER_ABI_METHOD_NAME = "addOwnerWithThreshold"
    private let REVOKE_DEVICE_ABI_METHOD_NAME = "removeOwner"
    
    /// Get encodedABI data for `addOwnerWithThreshold`
    ///
    /// - Parameters:
    ///   - abiMethodName: ABI method name
    ///   - ownerAddress: Address of owner
    ///   - threshold: Threshold value. Default is 1
    /// - Returns: Hex string of encodedABI
    /// - Throws: OstError
    func getAddOwnerWithThresholdExecutableData(ownerAddress: String,
                                                threshold: String = "1") throws -> String {
        
        let abiObject: ABIObject? = try getABI(ABI_NAME, forMethod: self.ADD_OWNER_ABI_METHOD_NAME)
        if (abiObject == nil) {
            throw OstError("u_ah_gs_gaowted_1", msg: "ABI for \(self.ADD_OWNER_ABI_METHOD_NAME) is not available.")
        }
        
        let addressTobeAdded = try EthereumAddress(hex:ownerAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(addressTobeAdded, BigInt(threshold)! )
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {     
            throw OstError("u_ah_gs_gaowted_2", OstErrorText.abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
    
    
    /// Get revoke device executable data
    ///
    /// - Parameters:
    ///   - prevOwner: Previous owner address
    ///   - owner: Device address to revoke
    ///   - threshold: Threshold value. Default is 1
    /// - Returns: Hex string of encodedABI
    /// - Throws: OstError
    func getRevokeDeviceWithThresholdExecutableData(prevOwner: String,
                                                    owner: String,
                                                    threshold: String = "1") throws -> String {
        
        let abiObject: ABIObject? = try getABI(ABI_NAME, forMethod: self.REVOKE_DEVICE_ABI_METHOD_NAME)
        if (abiObject == nil) {
            throw OstError("u_ah_gs_grdwted_1",
                           msg: "ABI for \(self.REVOKE_DEVICE_ABI_METHOD_NAME) is not available.")
        }
        
        let prevOwnerAddress = try EthereumAddress(hex:prevOwner, eip55: false)
        let ownerAddress = try EthereumAddress(hex:owner, eip55: false)
        
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(prevOwnerAddress, ownerAddress, BigInt(threshold)! )
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError("u_ah_gs_gaowted_2", OstErrorText.abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
    
    /// Get type data for SafeTx
    ///
    /// - Parameters:
    ///   - verifyingContract: Verifying contract address
    ///   - to: To address
    ///   - value: Value to transfter
    ///   - data: Data
    ///   - operation: Operation
    ///   - safeTxGas: gas
    ///   - dataGas: Data gas
    ///   - gasPrice: Gas price
    ///   - gasToken: Gas token
    ///   - refundReceiver: Refund receiver address
    ///   - nonce: Nonce
    /// - Returns: Type data dictionary
    /// - Throws: OstError
    func getSafeTxData(verifyingContract: String,
                       to: String,
                       value: String,
                       data: String,
                       operation: String,
                       safeTxGas: String,
                       dataGas: String,
                       gasPrice: String,
                       gasToken: String,
                       refundReceiver: String,
                       nonce: String) throws -> [String: Any] {
        
        let typedDataInput: [String: Any] = ["types": [ "EIP712Domain": [[ "name": "verifyingContract", "type": "address" ]],
                                                        "SafeTx": [[ "name": "to", "type": "address" ],
                                                                   [ "name": "value", "type": "uint256" ],
                                                                   [ "name": "data", "type": "bytes" ],
                                                                   [ "name": "operation", "type": "uint8" ],
                                                                   [ "name": "safeTxGas", "type": "uint256" ],
                                                                   [ "name": "dataGas", "type": "uint256" ],
                                                                   [ "name": "gasPrice", "type": "uint256" ],
                                                                   [ "name": "gasToken", "type": "address" ],
                                                                   [ "name": "refundReceiver", "type": "address" ],
                                                                   [ "name": "nonce", "type": "uint256" ]]
            ],
                                             "primaryType": "SafeTx",
                                             "domain": ["verifyingContract": verifyingContract],
                                             "message": ["to": to,
                                                         "value": value,
                                                         "data": data,
                                                         "operation": operation,
                                                         "safeTxGas": safeTxGas,
                                                         "dataGas": dataGas,
                                                         "gasPrice": gasPrice,
                                                         "gasToken": gasToken,
                                                         "refundReceiver": refundReceiver,
                                                         "nonce": nonce
            ]]
        
        return typedDataInput
    }
}
