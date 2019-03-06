//
//  OstPerform+AddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAuthorizeSession: OstAuthorizeBase {
    private let abiMethodNameForAuthorizeSession = "authorizeSession"
    
    private let spendingLimit: String
    private let expirationHeight: String
    private let onSuccess: ((OstSession)-> Void)
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - sessionAddress: Session address to authorize
    ///   - spendingLimit: Spending limit for transaction
    ///   - expirationHeight: Expiration height
    ///   - generateSignatureCallback: Callback to get signature
    ///   - onSuccess: Callback when flow successfull
    ///   - onFailure: Callback when flow failed
    init(userId: String,
         sessionAddress: String,
         spendingLimit: String,
         expirationHeight: String,
         generateSignatureCallback: @escaping ((String) -> (String?, String?)),
         onSuccess: @escaping ((OstSession)-> Void),
         onFailure: @escaping ((OstError) -> Void)) {
        
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        self.onSuccess = onSuccess
        
        super.init(userId: userId,
                   addressToAdd: sessionAddress,
                   generateSignatureCallback: generateSignatureCallback,
                   onFailure: onFailure)
    }
 
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try TokenHolder().getAddSessionExecutableData(abiMethodName: self.abiMethodNameForAuthorizeSession,
                                                                          sessionAddress: self.addressToAdd,
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
                                       "parameters": [self.addressToAdd, self.spendingLimit, self.expirationHeight]]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// API request for authorize session
    ///
    /// - Parameter params: API parameters for authorize session
    /// - Throws: OstError
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (ostSession) in
            self.onSuccess(ostSession)
        }, onFailure: { (ostError) in
            self.onFailure(ostError)
        })
    }
}
