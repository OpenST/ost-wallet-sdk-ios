//
//  OstRecoveryOwnerEntity.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRecoveryOwnerEntity: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    /// User status
    enum Status: String {
        // TODO: add detailed description of the status meaning.
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
