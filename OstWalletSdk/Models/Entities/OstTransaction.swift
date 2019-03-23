/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstTransaction: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "id"
    
    enum Status: String {
        case CREATED = "CREATED"
        case FAILED = "FAILED"
        case SUCCESS = "SUCCESS"
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
            return (OstTransaction.Status.SUCCESS.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
    
    var isStatusFailed: Bool {
        if let status: String = self.status {
            return (OstTransaction.Status.FAILED.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
}
