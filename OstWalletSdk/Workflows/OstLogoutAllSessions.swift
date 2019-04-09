/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstLogoutAllSessions: OstWorkflowEngine {
    static private let ostLogoutAllSessionsQueue = DispatchQueue(label: "com.ost.sdk.OstLogoutAllSessions", qos: .background)
    private let workflowTransactionCount = 1
    private let nullAddress = "0x0000000000000000000000000000000000000000"
    private let abiMethodNameForLogout = "logout"
    
    private var deviceManager: OstDeviceManager? = nil
    private var signature: String? = nil
    private var signer: String? = nil
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstLogoutAllSessions.ostLogoutAllSessionsQueue
    }
    
    /// Validate user and device
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        try isUserActivated()
        try isDeviceAuthorized()
    }

    /// Logout all sessions after device validated.
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        try fetchDeviceManager()
        
        let encodedABIHex = try TokenHolder().getLogoutExecutableData()
        let deviceManagerNonce: Int = self.deviceManager!.nonce
        
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                           to: self.currentUser!.tokenHolderAddress!,
                                                                           value: "0",
                                                                           data: encodedABIHex,
                                                                           operation: "0",
                                                                           safeTxGas: "0",
                                                                           dataGas: "0",
                                                                           gasPrice: "0",
                                                                           gasToken: self.nullAddress,
                                                                           refundReceiver: self.nullAddress,
                                                                           nonce: OstUtils.toString(deviceManagerNonce)!)
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any],
                                    primaryType: typedDataInput["primaryType"] as! String,
                                    domain: typedDataInput["domain"] as! [String: String],
                                    message: typedDataInput["message"] as! [String: Any])
        
        let signingHash = try! eip712.getEIP712Hash()
        let keyManager = OstKeyManager(userId: self.userId)
        self.signature = try keyManager.signWithDeviceKey(signingHash)
        self.signer = keyManager.getDeviceAddress()
        
        let rawCallData: String = getRawCallData()
        
        let params: [String: Any] = ["to": self.currentUser!.tokenHolderAddress!,
                                     "value": "0",
                                     "calldata": encodedABIHex,
                                     "raw_calldata": rawCallData,
                                     "operation": "0",
                                     "safe_tx_gas": "0",
                                     "data_gas": "0",
                                     "gas_price": "0",
                                     "nonce": OstUtils.toString(deviceManagerNonce)!,
                                     "gas_token": self.nullAddress,
                                     "refund_receiver": self.nullAddress,
                                     "signers": [self.signer!],
                                     "signatures": self.signature!
        ]
        
        try self.deviceManager?.incrementNonce()
        try logoutAllSessions(params: params)
    }
    
    /// Get device manager from server
    ///
    /// - Throws: OstError
    private func fetchDeviceManager() throws {
        var error: OstError? = nil
        let group: DispatchGroup = DispatchGroup()
        group.enter()
        try OstAPIDeviceManager(userId: self.userId)
            .getDeviceManager(
                onSuccess: { (ostDeviceManager) in
                    self.deviceManager = ostDeviceManager
                    group.leave()
            }) { (ostError) in
                
                error = ostError
                group.leave()
        }
        group.wait()
        
        if (nil != error) {
            throw error!
        }
    }
    
    /// Get raw call data for logout
    ///
    /// - Returns: Raw calldata JSON string
    private func getRawCallData() -> String {
        let callData: [String: Any] = ["method": self.abiMethodNameForLogout,
                                       "parameters":[]]
        return try! OstUtils.toJSONString(callData)!
    }
    
    /// Logout all sessions
    ///
    /// - Parameter params: Logout request parameters
    /// - Throws: OstError
    private func logoutAllSessions(params: [String: Any]) throws {
        var err: OstError? = nil
        var tokenHolder: OstTokenHolder? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPITokenHolder(userId: self.userId)
            .logout(params: params,
                    onSuccess: { (ostTokenHolder) in
                        tokenHolder = ostTokenHolder
                        group.leave()
            }, onFailure: { (error) in
                err = error
                group.leave()
            })
        group.wait()
        if (nil != err) {
            try? fetchDeviceManager()
            throw err!
        }
        self.postRequestAcknowledged(entity: tokenHolder!)
        OstKeyManager(userId: self.userId).deleteAllSessions()
        pollingForLogoutAllSessions(entity: tokenHolder!)
    }
    
    /// Polling for token holders
    ///
    /// - Parameter tokenHolder: TokenHolder entity
    private func pollingForLogoutAllSessions(entity: OstTokenHolder) {
        let successCallback: ((OstTokenHolder) -> Void) = { ostTokenHolder in
            self.postWorkflowComplete(entity: ostTokenHolder)
        }
        
        let failureCallback: ((OstError) -> Void) = { error in
            self.postError(error)
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
    
        OstLogoutPollingService(userId: self.userId,
                                successStatus: OstTokenHolder.Status.LOGGED_OUT.rawValue,
                                failureStatus: OstTokenHolder.Status.ACTIVE.rawValue,
                                workflowTransactionCount: self.workflowTransactionCount,
                                successCallback:successCallback,
                                failureCallback: failureCallback).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .logoutAllSessions)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .tokenHolder)
    }
}
