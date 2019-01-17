//
//  OstTokenHolderSessionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTokenHolderSession: OstBaseEntity {
    
}

public extension OstTokenHolderSession {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var token_holder_id : String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var blockHeight : String? {
        return data["blockHeight"] as? String ?? nil
    }
    
    var expiry_time : String? {
        return data["expiry_time"] as? String ?? nil
    }
    
    var spending_limit : String? {
        return data["spending_limit"] as? String ?? nil
    }
    
    var redemption_limit : String? {
        return data["redemption_limit"] as? String ?? nil
    }
}


extension OstTokenHolderSession{
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
    
    public func signTransaction(_ transaction: OstTokenHolderSession.Transaction) throws -> String {
        let txnDict: [String: String] = transaction.toDictionary()
        let eip1077Obj: EIP1077 = EIP1077(transaction: txnDict)
        let eip1077TxnHash = try eip1077Obj.toEIP1077transactionHash()
        
        guard let secureKey: OstSecureKey = try OstSecureKey.getSecKey(for: self.address!) else {
            return ""
        }
        
        return try OstCryptoImpls().signTx(eip1077TxnHash, withPrivatekey: secureKey.privateKey)
    }
}
