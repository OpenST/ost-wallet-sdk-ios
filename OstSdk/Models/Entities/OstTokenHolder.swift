//
//  OstTokenHolderEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTokenHolder: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    /// Store OstTokenHolder entity data in the data base and returns the OstTokenHolder model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstTokenHolderRepository
            .sharedTokenHolder
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstTokenHolder.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstTokenHolder.ENTITY_PARENT_IDENTIFIER
    }
}

public extension OstTokenHolder {
    /// Get user id from token holder
    var userId: String? {
        return data["user_id"] as? String
    }
    
    /// Get multisig id from token holder
    var multisigId: String? {
        return data["multisig_id"] as? String
    }
    
    /// Get token holder address
    var address: String? {
        return data["address"] as? String
    }
    
    /// Get token holder session
    var sessions: Array<String>? {
        return data["sessions"] as? Array<String> ?? nil
    }
    
    /// Get token holder execure rule call prefix
    var executeRuleCallPrefix: String? {
        return data["execute_rule_callprefix"] as? String ?? nil
    }
}
