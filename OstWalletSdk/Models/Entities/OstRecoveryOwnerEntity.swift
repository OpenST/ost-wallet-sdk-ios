/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstRecoveryOwnerEntity: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    /// User status
    enum Status: String {
        case AUTHORIZATION_FAILED = "AUTHORIZATION_FAILED"
        case AUTHORIZING = "AUTHORIZING"
        case AUTHORIZED = "AUTHORIZED"
        case REVOKING = "REVOKING"
        case REVOKED = "REVOKED"
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstRecoveryOwnerEntity.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstRecoveryOwnerEntity.ENTITY_PARENT_IDENTIFIER
    }        
}

public extension OstRecoveryOwnerEntity {
    /// Get name.
    var userId: String? {
        return self.data["user_id"] as? String
    }
    
    /// Get token holder address.
    var address: String? {
        return self.data["address"] as? String
    }
}

//MARK: - Status Checks
public extension OstRecoveryOwnerEntity {
    
    /// Check whether status is AUTHORIZATION_FAILED or not. returns true if status is AUTHORIZATION_FAILED.
    var isStatusAuthorizationFailed: Bool {
        if let status: String = self.status {
            return (OstRecoveryOwnerEntity.Status.AUTHORIZATION_FAILED.rawValue == status)
        }
        return false
    }
  
    /// Check whether status is AUTHORIZING or not. returns true if status is AUTHORIZING.
    var isStatusAuthorizing: Bool {
        if let status: String = self.status {
            return (OstRecoveryOwnerEntity.Status.AUTHORIZING.rawValue == status)
        }
        return false
    }
    
    /// Check whether status is AUTHORIZED or not. returns true if status is AUTHORIZED.
    var isStatusAuthorized: Bool {
        if let status: String = self.status {
            return (OstRecoveryOwnerEntity.Status.AUTHORIZED.rawValue == status)
        }
        return false
    }
    
    /// Check whether status is REVOKING or not. returns true if status is REVOKING.
    var isStatusRevoking: Bool {
        if let status: String = self.status {
            return (OstRecoveryOwnerEntity.Status.REVOKING.rawValue == status)
        }
        return false
    }
    
    /// Check whether status is REVOKED or not. returns true if status is REVOKED.
    var isStatusRevoked: Bool {
        if let status: String = self.status {
            return (OstRecoveryOwnerEntity.Status.REVOKED.rawValue == status)
        }
        return false
    }
}
