//
//  Pricer.swift
//  OstSdk
//
//  Created by aniket ayachit on 07/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class PricerRule: ABIHerlperBase {
    private let ABI_NAME = "PricerRule.abi"
    
    func getPayExecutableData(abiMethodName: String,
                              from: String,
                              toAddresses: [String],
                              amounts: [String],
                              currencyCode: String,
                              currencyPrice: String) throws -> String {
        
        let abiObject: ABIObject? = try getABI(ABI_NAME, forMethod: abiMethodName)
        if (abiObject == nil) {
            throw OstError("u_ah_tr_gdted_1", "ABI for \(abiMethodName) is not available.")
        }
        //from eth address
        let fromEthAddress = try EthereumAddress(hex:from, eip55: false)
        
        //to eth addresses
        var toEthereumAddresses : [EthereumAddress] = []
        for toAddress in toAddresses {
            let address = try EthereumAddress(hex:toAddress, eip55: false)
            toEthereumAddresses.append(address)
        }
        
        //amount in big int
        var amountsBigInt: [BigInt] = []
        for amount in amounts {
            amountsBigInt.append(BigInt(amount)!)
        }
        
        //currencyCode
        let currencyCodeInBytes = currencyCode.data(using: .utf8)!
        
        //currencyPrice in big int
        let currencyPriceInBigInt = BigInt(currencyPrice)!
        
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(fromEthAddress,
                                           toEthereumAddresses,
                                           amountsBigInt,
                                           currencyCodeInBytes,
                                           currencyPriceInBigInt)
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError("u_ah_tr_gdted_2", OstErrorText.abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
}
