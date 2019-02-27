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
    private static let DEVICE_STATUS_CREATED = "CREATED"
    private static let DEVICE_STATUS_REGISTERED = "REGISTERED"
    private static let DEVICE_STATUS_AUTHORIZING = "AUTHORIZING"
    private static let DEVICE_STATUS_AUTHORIZED = "AUTHORIZED"
    private static let DEVICE_STATUS_REVOKING = "REVOKING"
    private static let DEVICE_STATUS_REVOKED = "REVOKED"
    
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "user_id"
    
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
    class func getDeviceByParentId(parentId: String) throws -> [OstDevice]? {
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
    func isDeviceRegistered() -> Bool {
        let status = self.status
        if (status == nil) {
            return false
        }
        return [OstDevice.DEVICE_STATUS_REGISTERED,
                OstDevice.DEVICE_STATUS_AUTHORIZING,
                OstDevice.DEVICE_STATUS_AUTHORIZED].contains(status!)
    }
    
    /// Check if the device status is AUTHORIZING
    ///
    /// - Returns: `true` if status is AUTHORIZING otherwise `false`
    func isAuthorizing() -> Bool {
        let status = self.status
        if (status != nil) {
            return status! == OstDevice.DEVICE_STATUS_AUTHORIZING
        }
        return false
    }

    /// Check if the device status is AUTHORIZED
    ///
    /// - Returns: `true` if status is AUTHORIZED otherwise `false`
    func isAuthorized() -> Bool {
        let status = self.status
        if (status != nil) {
            return status! == OstDevice.DEVICE_STATUS_AUTHORIZED
        }
        return false
    }

    /// Check if the device status is REVOKING or REVOKED
    ///
    /// - Returns: `true` if status is REVOKING or REVOKED otherwise `false`
    func isDeviceRevoked() -> Bool {
        let status = self.status
        if (status == nil) {
            return true
        }
        return [OstDevice.DEVICE_STATUS_REVOKING,
                OstDevice.DEVICE_STATUS_REVOKED].contains(status!)
    }
    
    /// Check if the device status is CREATED
    ///
    /// - Returns: `true` if status is CREATED otherwise `false`
    func isCreated() -> Bool {
        let status = self.status
        if (status != nil) {
            return status! == OstDevice.DEVICE_STATUS_CREATED
        }
        return false
    }
}

public extension OstDevice {
    /// Get local entity id
    var localEntityId: String? {
        return data["local_entity_id"] as? String 
    }
    
    /// Get address
    var address: String? {
        return data["address"] as? String
    }
    
    /// Get api signer address
    var apiSignerAddress: String? {
        return data["api_signer_address"] as? String
    }
    
    /// Get multi sig id
    var multiSigId: String? {
        return data["multi_sig_id"] as? String
    }
    
    /// Get user id
    var userId: String? {
        return data["user_id"] as? String
    }
    
    /// Get device manage address
    var deviceManagerAddress: String? {
        return data["device_manager_address"] as? String
    }
}
