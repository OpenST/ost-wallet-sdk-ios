//
//  GenosisSafe.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class GnosisSafe: ABIHelperBase {
    
    private let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
    private let ABI_NAME = "GnosisSafe.abi"
    
    /// Get encodedABI data for `addOwnerWithThreshold`
    ///
    /// - Parameters:
    ///   - ownerAddress: Address of owner
    ///   - threshold: Threshold value. Default is 1
    /// - Returns: Hex string of encodedABI
    /// - Throws: 
    func getAddOwnerWithThresholdExecutableData(abiMethodName: String, ownerAddress: String, threshold: String = "1") throws -> String {
        let abiObject: ABIObject? = try getABI(ABI_NAME, forMethod: abiMethodName)
        if (abiObject == nil) {
            throw OstError("u_ah_gs_gaowted_1", "ABI for \(abiMethodName) is not available.")
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
    
    func getSafeTxData(verifyingContract: String, to: String, value: String, data: String,
                       operation: String, safeTxGas: String, dataGas: String, gasPrice: String,
                       gasToken: String, refundReceiver: String, nonce: String) throws -> [String: Any] {
        
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
