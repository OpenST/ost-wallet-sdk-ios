/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeSession: OstAuthorizeBase {
    private let abiMethodNameForAuthorizeSession = "authorizeSession"
    private let workflowTransactionCountForPolling = 1
    
    private let spendingLimit: String
    private let expirationHeight: String
    private let onRequestAcknowledged: ((OstSession)-> Void)
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
         onRequestAcknowledged: @escaping ((OstSession) -> Void),
         onSuccess: @escaping ((OstSession)-> Void),
         onFailure: @escaping ((OstError) -> Void)) {
        
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        self.onRequestAcknowledged = onRequestAcknowledged
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
        let encodedABIHex = try TokenHolder().getAddSessionExecutableData(sessionAddress: self.addressToAdd,
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
        var ostError: OstError? = nil
        var ostSession: OstSession? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (session) in
            ostSession = session
            group.leave()
        }, onFailure: { (error) in
            ostError = error
            group.leave()
        })
        group.wait()
        if (nil != ostError) {
            try? self.fetchDeviceManager()
            throw ostError!
        }
        self.onRequestAcknowledged(ostSession!)
        self.pollingForAuthorizeSession(ostSession!)
    }
    
    /// Polling service for Session
    ///
    /// - Parameter ostSession: session entity
    private func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.onSuccess(ostSession)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                try? self.fetchDeviceManager()
                self.onFailure(error)
            }
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstSessionPollingService(userId: ostSession.userId!,
                                 sessionAddress: ostSession.address!,
                                 successStatus: OstSession.Status.AUTHORIZED.rawValue,
                                 failureStatus: OstSession.Status.CREATED.rawValue,
                                 workflowTransactionCount: self.workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback).perform()
    }
}
