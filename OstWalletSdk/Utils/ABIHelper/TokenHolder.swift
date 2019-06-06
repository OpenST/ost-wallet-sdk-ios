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
    
    private let executeRuleString = "executeRule(address,bytes,uint256,bytes32,bytes32,uint8)"
    
    private let abiMethodNameForAuthorizeSession = "authorizeSession"
    private let abiMethodNameForLogout = "logout"

    /// Get add session executable data
    ///
    /// - Parameters:
    ///   - sessionAddress: Session address
    ///   - expirationHeight: Expiration height in sesconds
    ///   - spendingLimit: Spending limit
    /// - Returns: Encoded ABI hex string
    /// - Throws: OstError
    func getAddSessionExecutableData(sessionAddress: String,
                                     expirationHeight: String,
                                     spendingLimit: String) throws -> String {
        
        let abiObject: ABIObject = try! getABI(ABI_NAME, forMethod: self.abiMethodNameForAuthorizeSession)!
        
        let sessionAddressTobeAdded = try EthereumAddress(hex:sessionAddress, eip55: false)
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject, handler: solidityHander)
        let _invocation = function!.invoke(sessionAddressTobeAdded, BigInt(spendingLimit)!, BigInt(expirationHeight)!)
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError("u_ah_th_gased_2", .abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
    
    /// Logout executable data
    ///
    /// - Returns: Encoed ABI hex string
    /// - Throws: OstError
    func getLogoutExecutableData() throws -> String {
        
        let abiObject: ABIObject = try! getABI(ABI_NAME, forMethod: self.abiMethodNameForLogout)!
       
        let solidityHander = OstSolidityHandler()
        let function = SolidityNonPayableFunction(abiObject: abiObject, handler: solidityHander)
        let _invocation = function!.invoke()
        let ethereumData = _invocation.encodeABI();
        if (ethereumData == nil) {
            throw OstError("u_ah_th_gased_2", .abiEncodeFailed)
        }
        
        return ethereumData!.hex()
    }
    
    func getCallPrefix() throws -> String? {
        let soliditySha3 = try SoliditySha3.getHash(self.executeRuleString)
        return soliditySha3.substr(0, 10)
    }
}
