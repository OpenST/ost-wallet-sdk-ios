//
//  TokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class TokenHolder: ABIHerlperBase {
    let ABI_NAME = "TokenHolder.abi"
    
    override init() {
        super.init()
    }
    
    func getAddSessionExecutableData(abiMethodName: String, sessionAddress: String, expirationHeight: String, spendingLimit: String) throws -> String {
        
        let abiObject: ABIObject? = try getABI(ABI_NAME, forMethod: abiMethodName)
        if (abiObject == nil) {
            throw OstError("u_ah_th_gased_1", "ABI for \(abiMethodName) is not available.")
        }
        
        let sessionAddressTobeAdded = try EthereumAddress(hex:sessionAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject!, handler: solidityHander)
        let _invocation = function!.invoke(sessionAddressTobeAdded, BigInt(spendingLimit)!, BigInt(expirationHeight)!)
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError("u_ah_th_gased_2", OstErrorText.abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
}
