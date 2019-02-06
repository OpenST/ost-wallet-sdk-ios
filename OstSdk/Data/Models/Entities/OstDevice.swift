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
    
    static let OSTDEVICE_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstDevice? {
        return try OstDeviceRepository.sharedDevice.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstDevice
    }
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    static func getDeviceByParentId(parentId: String) throws -> [OstDevice]? {
        return try OstDeviceRepository.sharedDevice.getByParentId(parentId) as? [OstDevice]
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstDevice.getEntityIdentiferKey()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstDevice.OSTDEVICE_PARENTID])
    }
}

public extension OstDevice {
    var local_entity_id: String? {
        return data["local_entity_id"] as? String 
    }
    
    var address: String? {
        return data["address"] as? String
    }
    
    var personal_sign_address: String? {
        return data["personal_sign_address"] as? String
    }
    
    var multi_sig_id: String? {
        return data["multi_sig_id"] as? String
    }
    
    var user_id: String? {
        return data["user_id"] as? String
    }
    
    var device_manager_address: String? {
        return data["device_manager_address"] as? String
    }
}
