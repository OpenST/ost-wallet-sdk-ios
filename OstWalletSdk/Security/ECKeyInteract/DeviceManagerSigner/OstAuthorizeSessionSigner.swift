/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeSessionSigner: OstDeviceManagerSignerBase {
    private let abiMethodNameForAuthorizeSession = "authorizeSession"
    private let spendingLimit: String
    private let expirationHeight: String
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - sessionAddress: Session address to authorize
    ///   - spendingLimit: Spending limit for transaction
    ///   - expirationHeight: Expiration height
    ///   - keyManagerDelegate: OstKeyManagerDelegate
    init(userId: String,
         sessionAddress: String,
         spendingLimit: String,
         expirationHeight: String,
         keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        super.init(userId: userId,
                   address: sessionAddress,
                   keyManagerDelegate: keyManagerDelegate)
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try TokenHolder().getAddSessionExecutableData(sessionAddress: self.address,
                                                                          expirationHeight: self.expirationHeight,
                                                                          spendingLimit: self.spendingLimit)
        return encodedABIHex
    }
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getToAddress() -> String? {
        do {
            let user = try OstUser.getById(self.userId)
            return user?.tokenHolderAddress
        }catch {
            return nil
        }
    }
    
    /// Get raw calldata
    ///
    /// - Returns: raw calldata JSON string
    override func getRawCallData() -> String {
        let callData: [String: Any] = ["method": self.abiMethodNameForAuthorizeSession,
                                       "parameters": [self.address,
                                                      self.spendingLimit,
                                                      self.expirationHeight]]
        
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// Generate signature
    ///
    /// - Returns: Signature, SignerAddress
    override func generateSignature(_ signingHash: String) -> (String?, String?) {
        if let deviceAddress = self.keyManagerDelegate.getDeviceAddress(),
            let signature = try? self.keyManagerDelegate.signWithDeviceKey(signingHash) {
                return (signature, deviceAddress)
        }
        return (nil, nil)
    }
    
}
