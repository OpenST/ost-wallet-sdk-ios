/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class TokenHolder: ABIHelperBase {
    private let ABI_NAME = "TokenHolder.abi"

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
