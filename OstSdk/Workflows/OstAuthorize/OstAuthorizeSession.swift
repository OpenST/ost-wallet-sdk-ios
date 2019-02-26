//
//  OstPerform+AddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAuthorizeSession: OstAuthorizeBase {
    let abiMethodNameForAuthorizeSession = "authorizeSession"
    
    let spendingLimit: String
    let expirationHeight: String
    let onSuccess: ((OstSession)-> Void)
    
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
 
    override func getEncodedABI() throws -> String {
        let encodedABIHex = try GnosisSafe().getAddSessionExecutableData(abiMethodName: self.abiMethodNameForAuthorizeSession,
                                                                         sessionAddress: self.addressToAdd,
                                                                         expirationHeight: self.expirationHeight,
                                                                         spendingLimit: self.spendingLimit)
        return encodedABIHex
    }
    
    override func getToForTypedData() -> String? {
        do {
            let user = try OstUser.getById(self.userId)
            return user?.tokenHolderAddress
        }catch {
            return nil
        }
    }
    
    override func getRawCallData() -> String {
        let callData: [String: Any] = ["method": self.abiMethodNameForAuthorizeSession,
                                       "parameters": [self.addressToAdd, self.spendingLimit, self.expirationHeight]]
        return try! OstUtils.toJSONString(callData)!
    }
    
    override func apiRequestForAuthorize(params: [String: Any]) throws {
        try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (ostSession) in
            self.onSuccess(ostSession)
        }, onFailure: { (ostError) in
            Logger.log(message: "I am here - OstAuthSession");
            self.onFailure(ostError)
        })
    }
}
