//
//  OstSessionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSession: OstBaseEntity {
    
    static let OSTSESSION_PARENTID = "user_id"
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    static let SESSION_STATUS_INITIALIZING = "INITIALIZING"
    static let SESSION_STATUS_CREATED = "CREATED"
    static let SESSION_STATUS_AUTHORISED = "AUTHORISED"
    static let SESSION_STATUS_REVOKING = "REVOKING"
    static let SESSION_STATUS_REVOKED = "REVOKED"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstSession? {
        return try OstSessionRepository.sharedSession.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstSession
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstSession.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstSession.OSTSESSION_PARENTID] as Any?)
    }
    
    func incrementAndStoreNonce() throws {
        var params: [String: Any?] = self.data
        params["nonce"] = self.nonce + 1
        params["updated_timestamp"] = Date.timestamp()
        _ = try OstSession.parse(params)
    }
    
    func isInitializing() -> Bool {
        if (self.status != nil &&
            OstSession.SESSION_STATUS_INITIALIZING == self.status!.uppercased()) {
            return true
        }
        return false
    }
}

public extension OstSession {
    var address : String? {
        return data["address"] as? String
    }
    
    var userId : String? {
        return data["user_id"] as? String
    }
    
    var spendingLimit : Int? {
        return OstUtils.toInt(self.data["spending_limit"] as Any?)
    }
    
    var expirationHeight :  Int? {
        return OstUtils.toInt(self.data["expiration_height"] as Any?)
    }
    
    var nonce: Int {
        return OstUtils.toInt(data["nonce"] as Any?) ?? 0
    }
}


extension OstSession{
    public final class Transaction {
        public var from: String
        public var to: String = "0x"
        public var operationType: String = "0"
        public var txnCallPrefix: String = "0x"
        public var extraHash: String = "0x00"
        public var data: String = "0x"
        
        public var gas: Int = 0
        public var gasPrice: Int = 0
        public var gasToken: Int = 0
        public var nonce: Int = 0
        public var value: Int = 0
        
        public init(from: String) {
            self.from = from
        }
        
        func toDictionary() -> [String: String] {
            return [EIP1077.TX_FROM: from,
                    EIP1077.TX_TO: to,
                    EIP1077.TX_OPERATIONTYPE: operationType,
                    EIP1077.TX_CALLPREFIX: txnCallPrefix,
                    EIP1077.TX_EXTRAHASH: extraHash,
                    EIP1077.TX_DATA: data,
                    EIP1077.TX_GAS: String(gas),
                    EIP1077.TX_GASPRICE: String(gasPrice),
                    EIP1077.TX_GASTOKEN: String(gasToken),
                    EIP1077.TX_NONCE: String(nonce),
                    EIP1077.TX_VALUE: String(value)]
        }
    }
    
    public func signTransaction(_ transaction: OstSession.Transaction) throws -> String {
        guard let currentDevice: OstCurrentDevice = try OstUser.getById(self.userId!)!.getCurrentDevice() else {
            throw OstError.init("m_e_s_st_1", .deviceNotFound)            
        }
        
        let txnDict: [String: String] = transaction.toDictionary()
        let eip1077Obj: EIP1077 = EIP1077(transaction: txnDict)
        let eip1077TxnHash = try eip1077Obj.toEIP1077transactionHash()
        
        let secureKey: OstSecureKey = try OstSecureKeyRepository.sharedSecureKey.getById(self.id) as! OstSecureKey
        let ostSessionKeyInfo: OstSessionKeyInfo = OstSessionKeyInfo(sessionKeyData: secureKey.privateKeyData, isSecureEnclaveEncrypted: secureKey.isSecureEnclaveEnrypted)
        
        let privateKey: String = try currentDevice.decrypt(sessionKeyInfo: ostSessionKeyInfo)

        return try OstCryptoImpls().signTx(eip1077TxnHash, withPrivatekey: privateKey)
    }
}
