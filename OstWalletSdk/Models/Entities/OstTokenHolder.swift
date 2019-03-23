/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstTokenHolder: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    enum Status: String {
        case ACTIVE = "ACTIVE"
        case LOGGING_OUT = "LOGGING OUT"
        case LOGGED_OUT = "LOGGED OUT"
    }
    
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
    
    /// Get token holder entity
    ///
    /// - Parameter id: Token holder entity id
    /// - Returns: TokenHolder entity
    /// - Throws: OstError
    class func getById(_ id: String) throws -> OstTokenHolder? {
        return try OstTokenHolderRepository.sharedTokenHolder.getById(id) as? OstTokenHolder
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

public extension OstTokenHolder {
    
    /// Check whether token holder status is ACTIVE or not. returns true if status is ACTIVE.
    var isStatusActive: Bool {
        if let status: String = self.status {
            return (OstTokenHolder.Status.ACTIVE.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
    
    /// Check whether token holder status is LOGGING OUT or not. returns true if status is LOGGING OUT.
    var isStatusLoggingOut: Bool {
        if let status: String = self.status {
            return (OstTokenHolder.Status.LOGGING_OUT.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
    
    /// Check whether token holder status is LOGGED OUT or not. returns true if status is LOGGED OUT.
    var isStatusLoggedOut: Bool {
        if let status: String = self.status {
            return (OstTokenHolder.Status.LOGGED_OUT.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
}
