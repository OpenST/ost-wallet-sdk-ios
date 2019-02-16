//
//  GenosisSafe.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class GenosisSafe {
    
    init() {
        
    }
    
    func getAddOwnerWithThresholdExecutableData(ownerAddress: String, threshold: String = "1") throws -> String {
        let abiName: String = "addOwnerWithThreshold"
        
        let abiObject: ABIObject? = try getABIFor(methodName: abiName)
        if (abiObject == nil) {
            throw OstError.actionFailed("ABI for \(abiName) is not available.")
        }
        
        let spenderAddress = try EthereumAddress(hex:ownerAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(spenderAddress, BigInt("1") )
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError.actionFailed("encode abi failed.")
        }
        
        return ethereumData!.hex()
        //to: //contract addresss from user contract address
        try getSafeTxData(to: "0x98443ba43e5a55ff9c0ebeddfd1db32d7b1a949a", value: "0", data: ethereumData!.hex(), operation: "0", safeTxGas: "0", dataGas: "0", gasPrice: "0", gasToken: "0x0000000000000000000000000000000000000000", refundReceiver: "0x0000000000000000000000000000000000000000", nonce: "0")
    }
    
    func getABIFor(methodName: String) throws -> ABIObject? {
        let content = try OstBundle.getContentOf(file: "GnosisSafe.abi", fileExtension: "json")
        
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
    
    func getSafeTxData(to: String, value: String, data: String, operation: String, safeTxGas: String, dataGas: String, gasPrice: String, gasToken:        String, refundReceiver: String, nonce: String) throws -> String {
        
        let typedDataInput:[String: Any] = ["types": [ "EIP712Domain": [[ "name": "verifyingContract", "type": "address" ]],
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
                                            "domain": ["verifyingContract": to],
                                            "message": ["to": to,
                                                        "value": value,
                                                        "data": data,
                                                        "operation": operation,
                                                        "safeTxGas": safeTxGas,
                                                        "dataGas": dataGas,
                                                        "gasPrice": gasPrice,
                                                        "gasToken": gasToken,
                                                        "refundReceiver": refundReceiver,
                                                        "nonce": nonce]]
        
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
        let sign = try! eip712.getEIP712SignHash()
        print(sign)
        return sign
    }
}
