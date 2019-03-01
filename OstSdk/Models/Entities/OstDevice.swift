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
    
    enum Status: String {
        case CREATED = "CREATED"
        case REGISTERED = "REGISTERED"
        case RECOVERYING = "RECOVERYING"
        case AUTHORIZING = "AUTHORIZING"
        case AUTHORIZED = "AUTHORIZED"
        case REVOKING = "REVOKING"
        case REVOKED = "REVOKED"
    }
    
    static let OSTDEVICE_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstDevice? {
        return try OstDeviceRepository.sharedDevice.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstDevice
    }
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    class func getById(_ address: String) throws -> OstDevice {
        return try OstDeviceRepository.sharedDevice.getById(address) as! OstDevice
    }
    
    static func getDeviceByParentId(parentId: String) throws -> [OstDevice]? {
        return try OstDeviceRepository.sharedDevice.getByParentId(parentId) as? [OstDevice]
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstDevice.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstDevice.OSTDEVICE_PARENTID] as Any?)
    }
}

public extension OstDevice {
    public var address: String? {
        return getId();
    }

    public var apiSignerAddress: String? {
        return data["api_signer_address"] as? String
    }
    
    public var userId: String? {
        return data["user_id"] as? String
    }
    
    public var deviceName: String? {
        return data["device_name"] as? String
    }
    
    public var deviceUUID: String? {
        return data["device_uuid"] as? String
    }
    
    public var linkedAddress: String? {
        return data["linked_address"] as? String
    }
}

//check for status
public extension OstDevice {
    
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.CREATED.rawValue == status)
        }
        return false
    }
    
    var isStatusRegistered: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REGISTERED.rawValue == status)
        }
        return false
    }
    
    var isStatusAuthorized: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.AUTHORIZED.rawValue == status)
        }
        return false
    }
    
    var isStatusAuthorizing: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.AUTHORIZING.rawValue == status)
        }
        return false
    }
    
    var isStatusRevoking: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REVOKING.rawValue == status)
        }
        return false
    }
    
    var isStatusRevoked: Bool {
        if let status: String = self.status {
            return (OstDevice.Status.REVOKED.rawValue == status)
        }
        return false
    }
}
