//
//  OstSendTransaction.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

class OstExecuteTransaction: OstWorkflowBase, OstValidateDataProtocol {
    
    private let DIRECT_TRANSFER = "Direct Transfer"
    private let ABI_METHOD_NAME_DIRECT_TRANSFER = "directTransfers"
    
    typealias ExecuteTransactionPayloadParams =
        (ruleName:String, addresses:[String], amounts:[String], tokenId:String)
    
    /// Rule name
    private static let PAYLOAD_RULE_NAME_KEY = "rn"
    /// Token holder addresses
    private static let PAYLOAD_ADDRESSES_KEY = "ads"
    /// amounts to transfer
    private static let PAYLOAD_AMOUNTS_KEY = "ams"
    /// token id
    private static let PAYLOAD_TOKEN_ID_KEY = "tid"
    
    /// Get execute transaction params from qr-code payload
    ///
    /// - Parameter payload: qr-code payload
    /// - Returns: ExecuteTransactionPayloadParams
    /// - Throws: OstError
    class func getExecuteTransactionParamsFromQRPayload(_ payload: [String: Any?]) throws -> ExecuteTransactionPayloadParams {
        
        guard let ruleName: String = payload[OstExecuteTransaction.PAYLOAD_RULE_NAME_KEY] as? String else {
            throw OstError("w_et_getpfqrp_1", .invalidQRCode)
        }
        guard let addresses: [String] = payload[OstExecuteTransaction.PAYLOAD_ADDRESSES_KEY] as? [String] else {
            throw OstError("w_et_getpfqrp_2", .invalidQRCode)
        }
        guard let amounts: [String] = payload[OstExecuteTransaction.PAYLOAD_AMOUNTS_KEY] as? [String] else {
            throw OstError("w_et_getpfqrp_3", .invalidQRCode)
        }
        guard let tokenId: String = OstUtils.toString(payload[OstExecuteTransaction.PAYLOAD_TOKEN_ID_KEY] as Any?) else {
            throw OstError("w_et_getpfqrp_4", .invalidQRCode)
        }
        if (amounts.count != addresses.count) {
            throw OstError("w_et_getpfqrp_5", .invalidQRCode)
        }
        
        return (ruleName, addresses, amounts, tokenId)
    }
    
    private let ostExecuteTransactionQueue = DispatchQueue(label: "com.ost.sdk.OstExecuteTransaction", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let tokenHolderAddresses: [String]
    private let amounts: [String]
    private let ruleName: String
    private let tokenId: String
    
    private var rule: OstRule? = nil
    private var activeSession: OstSession? = nil
    private var calldata: String? = nil
    private var eip1077Hash: String? = nil
    private var signature: String? = nil
    private var isRetryAfterFetch = false
    
    /// Initialize Execute Transaction
    ///
    /// - Parameters:
    ///   - userId: Kit User id.
    ///   - ruleName: rule name to execute.
    ///   - tokenHolderAddresses: token holder address whome to transfer amount.
    ///   - amounts: amount to transfer.
    ///   - tokenId: token id.
    ///   - delegate: Callback.
    init(userId: String,
         ruleName: String,
         tokenHolderAddresses: [String],
         amounts: [String],
         tokenId: String,
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.tokenHolderAddresses = tokenHolderAddresses
        self.amounts = amounts
        self.ruleName = ruleName
        self.tokenId = tokenId
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostExecuteTransactionQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceAuthorized()
        
        if (self.currentUser!.tokenId! != self.tokenId) {
            throw OstError("w_et_p_3", OstErrorText.invalidTokenId)
        }
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        self.rule = try getRuleIfPresent()
        if (nil == self.rule) {
            try fetchTokenRules()
            self.rule = try getRuleIfPresent()
            if (nil == self.rule) {
                throw OstError("w_et_p_1", .rulesNotFound)
            }
        }
        
        guard let session = try getActiveSession() else {
            throw OstError("w_et_p_2", OstErrorText.sessionNotFound)
        }
        self.activeSession = session
        verifyData()
    }
    
    /// Get appropriate rule from datatabase
    ///
    /// - Throws: OstError
    private func getRuleIfPresent() throws -> OstRule? {
        if let rules = try OstRule.getByParentId(self.tokenId) {
            for rule in rules {
                if (self.ruleName.caseInsensitiveCompare(rule.name!) == .orderedSame &&
                    rule.tokenId?.caseInsensitiveCompare(self.tokenId) == .orderedSame) {
                    return rule
                }
            }
        }
        return nil
    }
    
    /// Get token rules from server
    private func fetchTokenRules() throws {
        var ostError: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        
        try OstAPIRule(userId: self.userId).getRules(onSuccess: { () in
            group.leave()
        }) { (error) in
            ostError = error
            group.leave()
        }
        group.wait()
        
        if (nil != ostError) {
            throw ostError!
        }
    }
    
    //TODO: - get addresses for KeyManager and get session from db.
    // validate and
    /// Get active session from db.
    private func getActiveSession() throws -> OstSession? {
        var ostSession: OstSession?  = nil
        if let activeSessions: [OstSession] = try OstSessionRepository.sharedSession.getActiveSessionsFor(parentId: self.userId) {
            for session in activeSessions {
                if (session.approxExpirationTimestamp > Date().timeIntervalSince1970) {
                    let totalTransactionSpendingLimit = try getTransactionSpendingLimit()
                    let spendingLimit = BigInt(session.spendingLimit ?? "0")
                    if spendingLimit >= totalTransactionSpendingLimit {
                        ostSession = session
                        break
                    }
                }
            }
        }
        return ostSession
    }
    
    /// Get total spending limit of transaction
    ///
    /// - Returns: BigInt of total transaciton amount
    /// - Throws: OstError
    private func getTransactionSpendingLimit() throws -> BigInt {
        var totalAmount: BigInt = BigInt("0")
        for amount in self.amounts {
            guard let amountInBigInt = BigInt(amount) else {
                throw OstError("w_et_gtsl_1", OstErrorText.invalidAmount)
            }
            totalAmount += amountInBigInt
        }
        return totalAmount
    }
    
    /// verify device from user.
    ///
    /// - Parameter device: OstDevice entity.
    private func verifyData() {
        var stringToConfirm: String = ""
        stringToConfirm += "rule name : \(self.ruleName)"
        
        for (i, address) in self.tokenHolderAddresses.enumerated() {
            stringToConfirm += "\n\(address): \(self.amounts[i])"
        }
        
        let workflowContext = OstWorkflowContext(workflowType: .executeTransaction);
        let contextEntity: OstContextEntity = OstContextEntity(entity: stringToConfirm, entityType: .string)
        DispatchQueue.main.async {
            self.delegate.verifyData(workflowContext: workflowContext,
                                     ostContextEntity: contextEntity,
                                     delegate: self)
        }
    }
    
    /// Callback from user about data verified to continue.
    public func dataVerified() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            self.generateHash()
            self.executeTransaction()
        }
    }
    
    /// Generate EIP1077 hash.
    private func generateHash() {
        do {
            self.calldata = try getCallData(ruleName: self.ruleName)
            if ( nil == self.calldata) {
                throw OstError("w_et_gh_1", OstErrorText.callDataFormationFailed)
            }
            
            let transaction: OstSession.Transaction = OstSession.Transaction(from: self.currentUser!.tokenHolderAddress!)
            transaction.to = self.rule!.address!
            transaction.data = self.calldata!
            transaction.nonce = OstUtils.toString(self.activeSession!.nonce)!
            transaction.txnCallPrefix = TokenRule.EXECUTE_RULE_CALLPREFIX
            
            self.eip1077Hash = try self.activeSession!.getEIP1077Hash(transaction)
            self.signature = try self.activeSession!.signTransaction(self.eip1077Hash!)
            
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Get call data for given rule name.
    ///
    /// - Parameter ruleName: rule name to execute transaction.
    /// - Returns: calldata
    /// - Throws: OstError
    private func getCallData(ruleName: String) throws -> String? {
        if (ruleName.caseInsensitiveCompare(DIRECT_TRANSFER) == .orderedSame) {
            return try TokenRule().getDirectTransfersExecutableData(abiMethodName: self.ABI_METHOD_NAME_DIRECT_TRANSFER,
                                                                    tokenHolderAddresses: self.tokenHolderAddresses,
                                                                    amounts: self.amounts)
        }
        return nil
    }
    
    /// Execute transaction.
    private func executeTransaction() {
        do {
            let rawCalldata: [String: Any] = ["method": self.ABI_METHOD_NAME_DIRECT_TRANSFER,
                                              "parameters": [self.tokenHolderAddresses, self.amounts]]
            let rawCalldataString = try OstUtils.toJSONString(rawCalldata)
            var params: [String: Any] = [:]
            params["to"] = self.rule!.address!
            params["raw_calldata"] = rawCalldataString
            params["nonce"] = OstUtils.toString(self.activeSession!.nonce)!
            params["calldata"] = self.calldata!
            params["signer"] = self.activeSession!.address!
            params["signature"] = self.signature!
            params["meta_property"] = [:]
            
            try self.activeSession!.incrementNonce()
            
            try OstAPITransaction(userId: self.userId)
                .executeTransaction(
                    params: params,
                    onSuccess: { (ostTransaction) in
                    
                        self.postRequestAcknowledged(entity: ostTransaction)
                        self.pollingForTransaction(transaction: ostTransaction)
                }) { (error) in
                    self.postError(error)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Fetch session if transaction failed and retry.
    private func fetchSessionAndRetry() {
        do {
            try OstAPISession(userId: self.userId).getSession(sessionAddress: self.activeSession!.address!, onSuccess: { (ostSession) in
                self.activeSession = ostSession
                self.isRetryAfterFetch = true
                self.perform()
            }) { (ostError) in
                self.postError(ostError)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Polling for checking transaction status
    private func pollingForTransaction(transaction: OstTransaction) {
        let successCallback: ((OstTransaction) -> Void) = { ostSession in
            self.postWorkflowComplete(entity: ostSession)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            if (self.isRetryAfterFetch) {
                self.postError(error)
            }else {
                self.fetchSessionAndRetry()
            }
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        
        OstTransactionPollingService(userId: self.userId,
                                     transaciotnId: transaction.id,
                                     workflowTransactionCount: self.workflowTransactionCountForPolling,
                                     successCallback: successCallback,
                                     failureCallback: failureCallback).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .executeTransaction)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .transaction)
    }
}
