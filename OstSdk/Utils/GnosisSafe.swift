//
//  GenosisSafe.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class GnosisSafe {
    
    let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
    
    init() {
        
    }
    
    /// Get encodedABI data for `addOwnerWithThreshold`
    ///
    /// - Parameters:
    ///   - ownerAddress: Address of owner
    ///   - threshold: Threshold value. Default is 1
    /// - Returns: Hex string of encodedABI
    /// - Throws: 
    func getAddOwnerWithThresholdExecutableData(abiMethodName: String, ownerAddress: String, threshold: String = "1") throws -> String {
        let abiObject: ABIObject? = try getABI("GnosisSafe.abi", forMethod: abiMethodName)
        if (abiObject == nil) {
            throw OstError.init("u_gaowted_1", "ABI for \(abiMethodName) is not available.")
        }
        
        let addressTobeAdded = try EthereumAddress(hex:ownerAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(addressTobeAdded, BigInt(threshold)! )
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError.init("u_gaowted_2", .abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
    
    func getAddSessionExecutableData(abiMethodName: String, sessionAddress: String, expirationHeight: String, spendingLimit: String) throws -> String {
        
        let abiObject: ABIObject? = try getABI("TokenHolder.abi", forMethod: abiMethodName)
        if (abiObject == nil) {
            throw OstError.init("u_gased_1", "ABI for \(abiMethodName) is not available.")
        }
        
        let sessionAddressTobeAdded = try EthereumAddress(hex:sessionAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(sessionAddressTobeAdded, BigInt(spendingLimit)!, BigInt(expirationHeight)!)
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError.init("u_gased_2", .abiEncodeFailed)            
        }
        
        return ethereumData!.hex()
    }
    
    func getABI(_ abiName: String, forMethod methodName: String) throws -> ABIObject? {
        let content = try OstBundle.getContentOf(file: abiName, fileExtension: "json")
        
        let contractJsonABI = content.data(using: .utf8)!
        let decoder = JSONDecoder()
        let abiArray = try decoder.decode([ABIObject].self, from: contractJsonABI)
        
        for abi in abiArray {
            if let abiName = abi.name {
                if (abiName == methodName) {
                    return abi
                }
            }
        }
        return nil
    }
    
    func getSafeTxData(to: String, value: String, data: String, operation: String, safeTxGas: String, dataGas: String, gasPrice: String, gasToken:        String, refundReceiver: String, nonce: String) throws -> [String: Any] {
        
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
                                                                  ]
            ],
                                            "primaryType": "SafeTx",
                                            "domain": ["verifyingContract": to],
                                            "message": ["to": to,
                                                        "value": value,
                                                        "data": data,
                                                        "operation": operation,
                                                        "safeTxGas": safeTxGas,
                                                        "dataGas": dataGas,
                                                        "gasPrice": gasPrice,
                                                        "gasToken": gasToken,
                                                        "refundReceiver": refundReceiver
                                                        ]]
        
        return typedDataInput
    }
}
