/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstUser: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "id"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "token_id"
    
    /// User status
    enum Status: String {
        case CREATED = "CREATED"
        case ACTIVATING = "ACTIVATING"
        case ACTIVATED = "ACTIVATED"
    }
    
    /// Store OstUser entity data in the data base and returns the OstUser model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstUserModelRepository
            .sharedUser
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get OstUser object from given user id
    ///
    /// - Parameter userId: User id
    /// - Returns: OstUser model object
    /// - Throws: OSTError
    class func getById(_ userId: String) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.getById(userId) as? OstUser
    }

    /// Initializer for OstUser
    ///
    /// - Parameters:
    ///   - id: User id
    ///   - tokenId: Token id
    /// - Throws: OstError
    class func initUser(forId id: String, withTokenId tokenId: String) throws -> OstUser {
        if let userObj = try OstUser.getById(id) {
            return userObj
        }
        
        let userEntityData = [
            "id": id,
            "token_id": tokenId,
            "status": OstUser.Status.CREATED.rawValue,
            "updated_timestamp": OstUtils.toString(Date.timestamp())
        ]
        
        try OstUser.storeEntity(userEntityData)
        return try OstUser.getById(id)!
    }

    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstUser.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstUser.ENTITY_PARENT_IDENTIFIER
    }

    /// Check if the current device is available or not
    ///
    /// - Returns: `true` if available else `false`
    func hasCurrentDevice() -> Bool {
        if let _ = getCurrentDevice() {
            return true
        }
        return false
    }

    /// Get current device model object
    ///
    /// - Returns: OstCurrentDevice model object
    @objc public func getCurrentDevice() -> OstCurrentDevice? {
        // if current device address is not available return nil
        guard let deviceAddress = OstKeyManagerGateway
            .getOstKeyManager(userId: self.id)
            .getDeviceAddress() else {
                
            return nil
        }
        
        do {
            // Check if the device data is available for the given device address
            guard let device: OstDevice = try OstDeviceRepository.sharedDevice.getById(deviceAddress) as? OstDevice else {
                return nil
            }
            
            // Create a OstCurrentDevice and return it
            let currentDevice = try OstCurrentDevice(device.data as [String : Any])
            return currentDevice
        } catch {
            return nil
        }        
    }
}

public extension OstUser {
    /// Get name.
    var name: String? {
        return self.data["name"] as? String
    }
    
    /// Get token holder address.
    var tokenHolderAddress: String? {
        return self.data["token_holder_address"] as? String
    }
    
    /// Get device manager address.
    var deviceManagerAddress: String? {
        return self.data["device_manager_address"] as? String
    }
    
    /// Get recovery owner address.
    var recoveryOwnerAddress: String? {
        return self.data["recovery_owner_address"] as? String
    }
    
    /// Get recovery address.
    var recoveryAddress: String? {
        return self.data["recovery_address"] as? String
    }
    
    /// Get token id.
    var tokenId: String? {
        return OstUtils.toString(self.data["token_id"] as Any)
    }
}

//MARK: - Status Checks
public extension OstUser {
    
    /// Check whether user status is CREATED or not. returns true if status is CREATED.
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstUser.Status.CREATED.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
    
    /// Check whether user status is ACTIVATED or not. returns true if status is ACTIVATED.
    var isStatusActivated: Bool {
        if let status: String = self.status {
            return (OstUser.Status.ACTIVATED.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
    
    /// Check whether user status is ACTIVATING or not. returns true if status is ACTIVATING.
    var isStatusActivating: Bool {
        if let status: String = self.status {
            return (OstUser.Status.ACTIVATING.rawValue.caseInsensitiveCompare(status) == .orderedSame)
        }
        return false
    }
}
