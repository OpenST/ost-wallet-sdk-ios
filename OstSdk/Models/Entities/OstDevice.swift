//
//  OstDeviceEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit

public class OstDevice: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
    /// Device status
    private enum Status: String {
        case CREATED = "CREATED"
        case REGISTERED = "REGISTERED"
        case RECOVERYING = "RECOVERYING"
        case AUTHORIZING = "AUTHORIZING"
        case AUTHORIZED = "AUTHORIZED"
        case REVOKING = "REVOKING"
        case REVOKED = "REVOKED"
    }
    
    /// Store OstDevice entity data in the data base and returns the OstDevice model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstDeviceRepository
            .sharedDevice
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get OstDevice object from given device address
    ///
    /// - Parameter deviceAddress: Device address
    /// - Returns: OstDevice model object
    /// - Throws: OSTError
    class func getById(_ deviceAddress: String) throws -> OstDevice? {
        return try OstDeviceRepository.sharedDevice.getById(deviceAddress) as? OstDevice
    }

    /// Get device from parent id
    ///
    /// - Parameter parentId: Parent id
    /// - Returns: Array<OstDevice>
    /// - Throws: OSTError
    class func getByParentId(parentId: String) throws -> [OstDevice]? {
        return try OstDeviceRepository.sharedDevice.getByParentId(parentId) as? [OstDevice]
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstDevice.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstDevice.ENTITY_PARENT_IDENTIFIER
    }
    
    /// Check if the device is already registered
    ///
    /// - Returns: `true` if registered otherwise `false`
    public func isDeviceRegistered() -> Bool {
        let status = self.status
        if (status == nil) {
            return false
        }
        return [Status.REGISTERED.rawValue,
                Status.AUTHORIZING.rawValue,
                Status.AUTHORIZED.rawValue].contains(status!)
    }

    /// Check if the device status is REVOKING or REVOKED
    ///
    /// - Returns: `true` if status is REVOKING or REVOKED otherwise `false`
    public func isDeviceRevoked() -> Bool {
        let status = self.status
        if (status == nil) {
            return true
        }
        return [Status.REVOKING.rawValue,
                Status.REVOKED.rawValue].contains(status!)
    }
}

public extension OstDevice {
    /// Get address
    public var address: String? {
        return data["address"] as? String
    }

    /// Get API signer address
    public var apiSignerAddress: String? {
        return data["api_signer_address"] as? String
    }

    /// Get User id
    public var userId: String? {
        return data["user_id"] as? String
    }
    
    /// Get device name
    public var deviceName: String? {
        return data["device_name"] as? String
    }
    
    /// Get device uuid
    public var deviceUUID: String? {
        return data["device_uuid"] as? String

    }
}

// Check for status
public extension OstDevice {
    /// Check if the device status is CREATED
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.CREATED.rawValue == status)
        }
        return false
    }
    
    /// Check if the device status is REGISTERED
    var isStatusRegistered: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REGISTERED.rawValue == status)
        }
        return false
    }
    
    /// Check if the device status is AUTHORIZED
    var isStatusAuthorized: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.AUTHORIZED.rawValue == status)
        }
        return false
    }
    
    /// Check if the device status is AUTHORIZING
    var isStatusAuthorizing: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.AUTHORIZING.rawValue == status)
        }
        return false
    }
    
    /// Check if the device status is REVOKING
    var isStatusRevoking: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REVOKING.rawValue == status)
        }
        return false
    }

    /// Check if the device status is REVOKED
    var isStatusRevoked: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REVOKED.rawValue == status)
        }
        return false
    }
}
