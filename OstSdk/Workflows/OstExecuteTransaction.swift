//
//  OstSendTransaction.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

/// Rule name
let PAYLOAD_RULE_NAME_KEY = "rn"
/// Token holder addresses
let PAYLOAD_ADDRESSES_KEY = "ads"
/// amounts to transfer
let PAYLOAD_AMOUNTS_KEY = "ams"
let PAYLOAD_TOKEN_ID_KEY = "tid"

class OstExecuteTransaction: OstWorkflowBase {
    
    private let DIRECT_TRANSFER = "Direct Transfer"
    private let ABI_METHOD_NAME_DIRECT_TRANSFER = "directTransfers"
    let workflowTransactionCountForPolling = 1
    
    let ostExecuteTransactionThread = DispatchQueue(label: "com.ost.sdk.OstExecuteTransaction", qos: .background)
    
    typealias ExecuteTransactionPayloadParams =
        (ruleName:String, addresses:[String], amounts:[String], tokenId:String)
    
    /// Get execute transaction params from qr-code payload
    ///
    /// - Parameter payload: qr-code payload
    /// - Returns: ExecuteTransactionPayloadParams
    /// - Throws: OstError
    class func getExecuteTransactionParamsFromQRPayload(_ payload: [String: Any?]) throws -> ExecuteTransactionPayloadParams {
        
        guard let ruleName: String = payload[PAYLOAD_RULE_NAME_KEY] as? String else {
            throw OstError("w_et_getpfqrp_1", .invalidQRCode)
        }
        guard let addresses: [String] = payload[PAYLOAD_ADDRESSES_KEY] as? [String] else {
            throw OstError("w_et_getpfqrp_2", .invalidQRCode)
        }
        guard let amounts: [String] = payload[PAYLOAD_AMOUNTS_KEY] as? [String] else {
            throw OstError("w_et_getpfqrp_3", .invalidQRCode)
        }
        guard let tokenId: String = OstUtils.toString(payload[PAYLOAD_TOKEN_ID_KEY] as Any?) else {
            throw OstError("w_et_getpfqrp_4", .invalidQRCode)
        }
        if (amounts.count != addresses.count) {
            throw OstError("w_et_getpfqrp_5", .invalidQRCode)
        }
        
        return (ruleName, addresses, amounts, tokenId)
    }
    
    let tokenHolderAddresses: [String]
    let amounts: [String]
    let ruleName: String
    let tokenId: String
    
    var rule: OstRule? = nil
    var activeSession: OstSession? = nil

    var calldata: String? = nil
    var eip1077Hash: String? = nil
    var signature: String? = nil
    var transaction: OstTransaction? = nil
    
    var isRetryAfterFetch = false
    
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
    
    /// Perform action for send transaction in background thread.
    override func perform() {
        ostExecuteTransactionThread.async {
            do {
                //validate user
                self.currentUser = try self.getUser()
                if (nil == self.currentUser) {
                    throw OstError("w_et_p_1", OstErrorText.userNotFound)
                }
                if (!self.currentUser!.isStatusActivated) {
                    throw OstError("w_et_p_2", OstErrorText.userNotActivated)
                }
                if (self.currentUser!.tokenId! != self.tokenId) {
                    throw OstError("w_et_p_3", OstErrorText.invalidTokenId)
                }
                
                //validate current device
                self.currentDevice = try self.getCurrentDevice()
                if (nil == self.currentDevice) {
                    throw OstError("w_et_p_4", OstErrorText.deviceNotFound)
                }
                if (!self.currentDevice!.isStatusAuthorized) {
                    throw OstError("w_et_p_4", OstErrorText.deviceNotAuthorized)
                }
                
                //fetch rule
                guard let rules = try OstRule.getByParentId(self.tokenId) else {
                    throw OstError("w_et_gtr_1", .rulesNotFound)
                }
                for rule in rules {
                    if (self.ruleName.caseInsensitiveCompare(rule.name!) == .orderedSame) {
                        self.rule = rule
                        break
                    }
                }
                if (nil == self.rule || self.rule?.tokenId?.caseInsensitiveCompare(self.tokenId) != .orderedSame) {
                   self.getToknRules()
                }else {
                    self.getActiveSession()
                }
            }catch let error{
                self.postError(error)
            }
        }
    }
    
    /// Get token rules from server
    func getToknRules() {
        do {
            try OstAPIRule(userId: self.userId).getRules(onSuccess: { () in
                do {
                    guard let rules = try OstRule.getByParentId(self.tokenId) else {
                        throw OstError("w_et_gtr_1", .rulesNotFound)
                    }
                    for rule in rules {
                        if (self.ruleName.caseInsensitiveCompare(rule.name!) == .orderedSame) {
                            throw OstError("w_et_gtr_2", OstErrorText.rulesNotFound)
                        }else {
                            self.getActiveSession()
                        }
                    }
                    
                }catch  let error {
                    self.postError(error)
                }
            }) { (error) in
                self.postError(error)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    //TODO: - get addresses for KeyManager and get session from db.
    // validate and
    /// Get active session from db.
    func getActiveSession() {
        do {
            if (nil == self.activeSession) {
                if let activeSessions: [OstSession] = try OstSessionRepository.sharedSession.getActiveSessionsFor(parentId: self.userId) {
                    for session in activeSessions {
                        //TODO: check session expiry time.
                        let totalTransactionSpendingLimit = try getTransactionSpendingLimit()
                        let spendingLimit = BigInt(session.spendingLimit ?? "0")
                        if spendingLimit >= totalTransactionSpendingLimit {
                            self.activeSession = session
                            self.generateHash()
                            return
                        }
                        
                    }
                }
                throw OstError("w_et_gas_1", OstErrorText.sessionNotFound)
            }
            self.generateHash()
        }catch let error{
            self.postError(error)
        }
    }
    
    /// Get total spending limit of transaction
    ///
    /// - Returns: BigInt of total transaciton amount
    /// - Throws: OstError
    func getTransactionSpendingLimit() throws -> BigInt {
        var totalAmount: BigInt = BigInt("0")
        for amount in self.amounts {
            guard let amountInBigInt = BigInt(amount) else {
                throw OstError("w_et_gtsl_1", OstErrorText.invalidAmount)
            }
            totalAmount = totalAmount + amountInBigInt
        }
        return totalAmount
    }
    
    /// Generate EIP1077 hash.
    func generateHash() {
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
            
            self.executeTransaction()
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Get call data for given rule name.
    ///
    /// - Parameter ruleName: rule name to execute transaction.
    /// - Returns: calldata
    /// - Throws: OstError
    func getCallData(ruleName: String) throws -> String? {
        if (ruleName.caseInsensitiveCompare(DIRECT_TRANSFER) == .orderedSame) {
            return try TokenRule().getDirectTransfersExecutableData(abiMethodName: self.ABI_METHOD_NAME_DIRECT_TRANSFER,
                                                                    tokenHolderAddresses: self.tokenHolderAddresses,
                                                                    amounts: self.amounts)
        }
        return nil
    }
    
    /// Execute transaction.
    func executeTransaction() {
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
            
            try OstAPITransaction(userId: self.userId).executeTransaction(params: params,
                                                                          onSuccess: { (ostTransaction) in
                                                                            self.transaction = ostTransaction
                                                                            self.postRequestAcknowledged(entity: ostTransaction)
                                                                            self.pollingForTransaction()
            }) { (error) in
                if (self.isRetryAfterFetch) {
                    self.postError(error)
                }else {
                    self.fetchSessionAndRetry()
                }
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Fetch session if transaction failed and retry.
    func fetchSessionAndRetry() {
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
    
    func pollingForTransaction() {
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
                                     transaciotnId: transaction!.id,
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
