//
//  OstSessionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSession: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    /// Session status
    enum Status: String {
        // TODO: add detailed description of the status meaning.
        case INITIALIZING = "INITIALIZING"
        case CREATED = "CREATED"
        case AUTHORISED = "AUTHORISED"
        case REVOKING = "REVOKING"
        case REVOKED = "REVOKED"
    }
    
    /// Store OstSession entity data in the data base
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OstError
    static func storeEntity(_ entityData: [String: Any?]) throws {
        try OstSessionRepository
            .sharedSession
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get OstRule object from given address
    ///
    /// - Parameter address: Session address
    /// - Returns: OstSession model object
    /// - Throws: OSTError
    class func getById(_ address: String) throws -> OstSession? {
        return try OstSessionRepository.sharedSession.getById(address) as? OstSession
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstSession.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstSession.ENTITY_PARENT_IDENTIFIER
    }
    
    /// Increment nonce and store it in dabatabase
    ///
    /// - Throws: OstError
    func incrementNonce() throws {
        var params: [String: Any?] = self.data
        params["nonce"] = self.nonce + 1
        params["updated_timestamp"] = Date.timestamp()
        try OstSession.storeEntity(params)
    }
}

extension OstSession {
    /// Check if the session is created
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstSession.Status.CREATED.rawValue == status)
        }
        return false
    }
    
    /// Check if the session is initializing
    var isStatusInitializing: Bool {
        if let status: String = self.status {
            return (OstSession.Status.INITIALIZING.rawValue == status)
        }
        return false
    }
    
    /// Check if the session is authorized
    var isStatusAuthoried: Bool {
        if let status: String = self.status {
            return (OstSession.Status.AUTHORISED.rawValue == status)
        }
        return false
    }
    
    /// Check if the session is revoking
    var isStatusRevoking: Bool {
        if let status: String = self.status {
            return (OstSession.Status.REVOKING.rawValue == status)
        }
        return false
    }
    
    /// Check if the session is revoked
    var isStatusRevoked: Bool {
        if let status: String = self.status {
            return (OstSession.Status.REVOKED.rawValue == status)
        }
        return false
    }
    
}

public extension OstSession {
    /// Get session address
    var address : String? {
        return data["address"] as? String
    }
    
    /// Get user id
    var userId : String? {
        return data["user_id"] as? String
    }
    
    /// Get spending limit
    var spendingLimit : Int? {
        return OstUtils.toInt(self.data["spending_limit"] as Any?)
    }
    
    /// Get expiration height
    var expirationHeight :  Int? {
        return OstUtils.toInt(self.data["expiration_height"] as Any?)
    }
    
    /// Get nonce
    var nonce: Int {
        return OstUtils.toInt(data["nonce"] as Any?) ?? 0
    }
}

/*
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
*/
