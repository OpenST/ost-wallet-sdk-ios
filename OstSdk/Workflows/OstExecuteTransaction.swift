//
//  OstSendTransaction.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

public enum OstExecuteTransactionType: String {
    case ExecuteTransactionTypeDirectTransfer = "Direct Transfer"
    case ExecuteTransactionTypePay = "Pricer"
}

class OstExecuteTransaction: OstWorkflowBase {

    private let ABI_METHOD_NAME_DIRECT_TRANSFER = "directTransfers"
    private let ABI_METHOD_NAME_PAY = "pay"
    
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
        
        return (ruleName, addresses, amounts, tokenId)
    }
    
    private let ostExecuteTransactionQueue = DispatchQueue(label: "com.ost.sdk.OstExecuteTransaction", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let toAddresses: [String]
    private let amounts: [String]
    private let ruleName: String
    private let tokenId: String
    
    private var rule: OstRule? = nil
    private var activeSession: OstSession? = nil
    private var calldata: String? = nil
    private var eip1077Hash: String? = nil
    private var signature: String? = nil
    private var rawCalldata: String? = nil
    private var pricePoint: [String: Any]? = nil
    
    /// Initialize Execute Transaction
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - ruleName: Rule name to execute.
    ///   - toAddresses: Address whome to transfer amount.
    ///   - amounts: Amount to transfer.
    ///   - tokenId: Token id.
    ///   - delegate: Callback.
    init(userId: String,
         ruleName: String,
         toAddresses: [String],
         amounts: [String],
         tokenId: String,
         delegate: OstWorkFlowCallbackDelegate) {
        
        self.toAddresses = toAddresses
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
            throw OstError("w_et_vp_1", OstErrorText.invalidTokenId)
        }
        
        let allowedRuleNames = [OstExecuteTransactionType.ExecuteTransactionTypeDirectTransfer.rawValue.uppercased(),
                                OstExecuteTransactionType.ExecuteTransactionTypePay.rawValue.uppercased()]
        if (!allowedRuleNames.contains(self.ruleName.uppercased())) {
            throw OstError("w_et_vp_2", OstErrorText.invalidRuleName)
        }
        
        let filteredAddresses = toAddresses.filter({$0 != ""})
        if (amounts.count != filteredAddresses.count) {
            throw OstError("w_et_vp_3", .invalidAddressToTransfer)
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
        
        switch self.ruleName.uppercased() {
        case OstExecuteTransactionType.ExecuteTransactionTypePay.rawValue.uppercased():
            try self.processForPricer()
            
        case OstExecuteTransactionType.ExecuteTransactionTypeDirectTransfer.rawValue.uppercased():
            try self.processForDirectTransfer()
            
        default:
            return
        }
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
    
    /// Generate EIP1077 hash.
    private func createSignatureForTransaction() throws {
        let transaction: OstSession.Transaction = OstSession.Transaction(from: self.currentUser!.tokenHolderAddress!)
        transaction.to = self.rule!.address!
        transaction.data = self.calldata!
        transaction.nonce = OstUtils.toString(self.activeSession!.nonce)!
        transaction.txnCallPrefix = TokenRule.EXECUTE_RULE_CALLPREFIX
        
        self.eip1077Hash = try self.activeSession!.getEIP1077Hash(transaction)
        self.signature = try self.activeSession!.signTransaction(self.eip1077Hash!)
    }
    
    /// Execute transaction.
    private func executeTransaction() {
        do {
            var params: [String: Any] = [:]
            params["to"] = self.rule!.address!
            params["raw_calldata"] = self.rawCalldata!
            params["nonce"] = OstUtils.toString(self.activeSession!.nonce)!
            params["calldata"] = self.calldata!
            params["signer"] = self.activeSession!.address!
            params["signature"] = self.signature!
            params["meta_property"] = [:]
            
            try? self.activeSession!.incrementNonce()
            
            try OstAPITransaction(userId: self.userId)
                .executeTransaction(
                    params: params,
                    onSuccess: { (ostTransaction) in
                        self.postRequestAcknowledged(entity: ostTransaction)
                        self.pollingForTransaction(transaction: ostTransaction)
                }) { (error) in
                    self.fetchSession(error: error)
            }
        }catch let error {
            self.fetchSession(error: error as! OstError)
        }
    }
    
    /// Fetch session if transaction failed and retry.
    private func fetchSession(error: OstError) {
        do {
            try OstAPISession(userId: self.userId).getSession(sessionAddress: self.activeSession!.address!, onSuccess: { (ostSession) in
                self.postError(error)
            }) { (ostError) in
                self.postError(error)
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
            self.fetchSession(error: error)            
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

//MARK: - Execute transaction for pay
extension OstExecuteTransaction {
    
    /// process for pricer
    private func processForPricer() throws {
        if (nil == self.pricePoint) {
            try fetchPricePoint()
            if nil == self.pricePoint {
                throw OstError("w_et_pfdt_1", OstErrorText.callDataFormationFailed)
            }
        }
        self.calldata = try getCallDataForPricerRule()
        if ( nil == self.calldata) {
            throw OstError("w_et_pfdt_2", OstErrorText.callDataFormationFailed)
        }
        
        try createSignatureForTransaction()
        try createRawCallDataForPay()
        executeTransaction()
    }
    
    /// Fetch price point from server
    ///
    /// - Throws: OstError
    private func fetchPricePoint() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIChain(userId: self.userId)
            .getPricePoint(onSuccess: { (pricePointDict) in
                self.pricePoint = pricePointDict
                group.leave()
            }, onFailure: { (ostError) in
                err = ostError
                group.leave()
            })
        group.wait()
        
        if (nil != err) {
            throw err!
        }
    }
    
    /// Get call data for given rule name.
    ///
    /// - Parameter ruleName: rule name to execute transaction.
    /// - Returns: calldata
    /// - Throws: OstError
    private func getCallDataForPricerRule() throws -> String? {
        
        let currencyPriceInWei = try getCurrencyValueInWei()
        return try PricerRule().getPayExecutableData(abiMethodName: self.ABI_METHOD_NAME_PAY,
                                                     from: self.currentUser!.tokenHolderAddress!,
                                                     toAddresses: self.toAddresses,
                                                     amounts: self.amounts,
                                                     currencyCode: OstConstants.OST_PRICE_POINT_CURRENCY_SYMBOL,
                                                     currencyPrice: currencyPriceInWei
        )
    }
    
    /// Get currency value in Wei
    ///
    /// - Returns: Currency in wei
    /// - Throws: OstError
    private func getCurrencyValueInWei() throws -> String {
        
        guard let ostDict = self.pricePoint![OstConstants.OST_PRICE_POINT_TOKEN_SYMBOL] as? [String: Any] else {
            throw OstError("w_et_gcviw_1", OstErrorText.pricePointNotFound)
        }
        
        let fiatValInString = String(format: "%@", ostDict[OstConstants.OST_PRICE_POINT_CURRENCY_SYMBOL] as! CVarArg)
        let components = fiatValInString.split(separator: ".")
        var exponent: Int
        var afterDecimalString: Substring = ""
        if components.count == 1 {
            exponent = 0
        }else if components.count == 2 {
            afterDecimalString = components[1]
            while (afterDecimalString.hasSuffix("0") && afterDecimalString.count>0) {
                afterDecimalString = afterDecimalString.dropLast()
            }
            exponent = afterDecimalString.count
        }else {
            throw OstError("w_et_gcviw_2", OstErrorText.invalidPricePoint)
        }
        
        let pricePointNumber = BigInt("\( components[0])\(afterDecimalString)")
        if (nil == pricePointNumber) {
            throw OstError("w_et_gcviw_2", OstErrorText.invalidPricePoint)
        }
        
        guard let decimal = OstUtils.toInt(ostDict["decimals"] as Any) else {
            throw OstError("w_et_gcviw_2", OstErrorText.callDataFormationFailed)
        }
        
        let finalExponentComponent = decimal-exponent
        
        let currencyPriceInWei = pricePointNumber! * BigInt(10).power(finalExponentComponent)
        return (currencyPriceInWei.description)
    }
    
    /// Create raw call data for pay
    ///
    /// - Throws: OstError
    private func createRawCallDataForPay() throws {
        let currencyPriceInWei = try getCurrencyValueInWei()
        let rawCalldata: [String: Any] = ["method": self.ABI_METHOD_NAME_PAY,
                                          "parameters": [self.currentUser!.tokenHolderAddress!,
                                                         self.toAddresses,
                                                         self.amounts,
                                                         OstConstants.OST_PRICE_POINT_CURRENCY_SYMBOL,
                                                         currencyPriceInWei]]
        self.rawCalldata = try OstUtils.toJSONString(rawCalldata)
    }
}

//MARK: - Execute transaction for direct transfer
extension OstExecuteTransaction {
    
    /// process for direct transfer
    private func processForDirectTransfer() throws  {
        self.calldata = try getCallDataForDirectTransfer()
        if ( nil == self.calldata) {
            throw OstError("w_et_pfdt_1", OstErrorText.callDataFormationFailed)
        }
        
        try createSignatureForTransaction()
        try createRawCallDataForDirectTransfer()
        executeTransaction()
    }
    
    /// Get call data for given rule name.
    ///
    /// - Parameter ruleName: rule name to execute transaction.
    /// - Returns: calldata
    /// - Throws: OstError
    private func getCallDataForDirectTransfer() throws -> String? {
        return try TokenRule().getDirectTransfersExecutableData(abiMethodName: self.ABI_METHOD_NAME_DIRECT_TRANSFER,
                                                                tokenHolderAddresses: self.toAddresses,
                                                                amounts: self.amounts)
    }
    
    /// Create raw call data for direct transfer
    ///
    /// - Throws: OstError
    private func createRawCallDataForDirectTransfer() throws {
        let rawCalldata: [String: Any] = ["method": self.ABI_METHOD_NAME_DIRECT_TRANSFER,
                                          "parameters": [self.toAddresses, self.amounts]]
        self.rawCalldata = try OstUtils.toJSONString(rawCalldata)
    }
}
