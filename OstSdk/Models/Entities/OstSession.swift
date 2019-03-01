//
//  OstSessionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

public class OstSession: OstBaseEntity {
    
    static let OSTSESSION_PARENTID = "user_id"
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    enum Status: String {
        case INITIALIZING = "INITIALIZING"
        case CREATED = "CREATED"
        case AUTHORIZED = "AUTHORIZED"
        case AUTHORIZING = "AUTHORIZING"
        case REVOKING = "REVOKING"
        case REVOKED = "REVOKED"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstSession? {
        return try OstSessionRepository.sharedSession.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstSession
    }
    
    class func getById(_ address: String) throws -> OstSession? {
        return try OstSessionRepository.sharedSession.getById(address) as? OstSession
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstSession.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstSession.OSTSESSION_PARENTID] as Any?)
    }
    
    func incrementAndUpdateNonce() throws {
        var updatedData: [String: Any?] = self.data
        updatedData["nonce"] = OstUtils.toString(nonce+1)
        updatedData["updated_timestamp"] = OstUtils.toString(Date.timestamp())
        _ = try OstSession.parse(updatedData)
    }
}

public extension OstSession {
    var address : String? {
//        return "0xeE80C0A613C5c026C08EE1cA9330a626747CE29f"
        return data["address"] as? String
    }
    
    var userId : String? {
        return data["user_id"] as? String
    }
    
    var spendingLimit : BigInt? {
        guard let spendingLimit: String = OstUtils.toString(self.data["spending_limit"] as Any?) else {
            return nil
        }
        return BigInt(spendingLimit)
    }
    
    var expirationHeight : Int? {
        return OstUtils.toInt(self.data["expiration_height"] as Any?)
    }
    
    var nonce: Int {
        return OstUtils.toInt(data["nonce"] as Any?) ?? 0
    }
}

public extension OstSession {
    /// Check Session status. returns true of status is CREATED
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstSession.Status.CREATED.rawValue == status)
        }
        return false
    }
    
    /// Check Session status. returns true of status is INITIALIZING
    var isStatusInitializing: Bool {
        if let status: String = self.status {
            return (OstSession.Status.INITIALIZING.rawValue == status)
        }
        return false
    }
    /// Check Session status. returns true of status is AUTHORIZED
    var isStatusAuthorized: Bool {
        if let status: String = self.status {
            return (OstSession.Status.AUTHORIZED.rawValue == status)
        }
        return false
    }
    
    /// Check Session status. returns true of status is AUTHORIZING
    var isStatusAuthorizing: Bool {
        if let status: String = self.status {
            return (OstSession.Status.AUTHORIZING.rawValue == status)
        }
        return false
    }
    
    /// Check Session status. returns true of status is REVOKING
    var isStatusRevoking: Bool {
        if let status: String = self.status {
            return (OstSession.Status.REVOKING.rawValue == status)
        }
        return false
    }
    
    /// Check Session status. returns true of status is REVOKED
    var isStatusRevoked: Bool {
        if let status: String = self.status {
            return (OstSession.Status.REVOKED.rawValue == status)
        }
        return false
    }
}

extension OstSession{
    class Transaction {
        let from: String
        var to: String = "0x"
        var value: String = "0"
        var gasPrice: String = "0"
        var gas: String = "0"
        var data: String = "0x"
        var nonce: String = "0"
        var txnCallPrefix: String = "0x"
        
        public init(from: String) {
            self.from = from
        }
        
        func toDictionary() -> [String: String] {
            return [EIP1077.TX_FROM: from,
                    EIP1077.TX_TO: to,
                    EIP1077.TX_VALUE: value,
                    EIP1077.TX_GASPRICE: String(gasPrice),
                    EIP1077.TX_GAS: String(gas),
                    EIP1077.TX_DATA: data,
                    EIP1077.TX_NONCE: String(nonce),
                    EIP1077.TX_CALLPREFIX: txnCallPrefix]
        }
    }
    
    func getEIP1077Hash(_  transaction: OstSession.Transaction) throws -> String {
        let txnDict: [String: String] = transaction.toDictionary()
        let eip1077Obj: EIP1077 = EIP1077(transaction: txnDict)
        return try eip1077Obj.toEIP1077transactionHash()
    }
    
    func signTransaction(_ transactionHash: String) throws -> String {
        guard let currentDevice: OstCurrentDevice = try OstUser.getById(self.userId!)!.getCurrentDevice() else {
            throw OstError.init("m_e_s_st_1", .deviceNotFound)            
        }
        
        let secureKey: OstSecureKey = try OstSecureKeyRepository.sharedSecureKey.getById(self.address!) as! OstSecureKey
        let ostSessionKeyInfo: OstSessionKeyInfo = OstSessionKeyInfo(sessionKeyData: secureKey.privateKeyData, isSecureEnclaveEncrypted: secureKey.isSecureEnclaveEnrypted)
        
        let privateKey: String = try currentDevice.decrypt(sessionKeyInfo: ostSessionKeyInfo)
        
        return try OstCryptoImpls().signTx(transactionHash, withPrivatekey: privateKey)
    }
}
