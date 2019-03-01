//
//  OstTransactionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTransaction: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "transaction_hash"
    
    enum Status: String {
        case CREATED = "CREATED"
        case FAILED = "FAILED"
        case SUCCESS = "SUCCESS"
    }
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }

        /// Store OstTransaction entity data in the data base and returns the OstTransaction model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Returns: OstDeviceManager model object
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstTransactionRepository
            .sharedTransaction
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get OstTransaction object from given transaction hash
    ///
    /// - Parameter transactionHash: Transaction hash
    /// - Returns: OstTransaction model object
    /// - Throws: OSTError
    class func getById(_ transactionHash: String) throws -> OstTransaction? {
        return try OstTransactionRepository.sharedTransaction.getById(transactionHash) as? OstTransaction
    }
}

public extension OstTransaction {
    /// Get local entity id
    var localEntityId : String? {
        return data["local_entity_id"] as? String
    }
    
    /// Get user id
    var userId : String? {
        return data["user_id"] as? String
    }
    
    /// Get token holder address
    var tokenHolderAddress : String? {
        return data["token_holder_address"] as? String
    }
    
    /// Get rule id
    var ruleId : String? {
        return data["rule_id"] as? String
    }
    
    /// Get method
    var method : String? {
        return data["method"] as? String
    }
    
    /// Get params
    var params : String? {
        return data["params"] as? String
    }
    
    /// Get session
    var session : String? {
        return data["session"] as? String
    }
    
    /// Get executable rule payload
    var executeRulePayload : [String: String]? {
        return data["execute_rule_payload"] as? [String:String]
    }
    
    /// Get gas price
    var gasPrice: Int? {
        return OstUtils.toInt(data["gas_price"] as Any?) 
    }
}

//Get transaction status
public extension OstTransaction {
    var isStatusSuccess: Bool {
        if let status: String = self.status {
            return (OstTransaction.Status.SUCCESS.rawValue == status)
        }
        return false
    }
    
    var isStatusFailed: Bool {
        if let status: String = self.status {
            return (OstTransaction.Status.FAILED.rawValue == status)
        }
        return false
    }
}
