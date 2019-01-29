//
//  OstDeviceManagerOperationEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstDeviceManagerOperation: OstBaseEntity {
    
    static let OstDeviceManager_OPERATION_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstDeviceManagerOperation? {
        return try OstDeviceManagerOperationRepository.sharedDeviceManagerOperation.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstDeviceManagerOperation ?? nil
    }
    
    static func getEntityIdentifer() -> String {
        return "id"
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstDeviceManagerOperation.getEntityIdentifer()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstDeviceManagerOperation.OstDeviceManager_OPERATION_PARENTID])
    }
}


public extension OstDeviceManagerOperation {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var token_holder_address : String? {
        return data["token_holder_address"] as? String ?? nil
    }
    
    var kind : String? {
        return data["kind"] as? String ?? nil
    }
    
    var encoded_data : String? {
        return data["encoded_data"] as? String ?? nil
    }
    
    var raw_data : [String: Any]? {
        return data["raw_data"] as? [String: Any] ?? nil
    }
    
    var signatures : [String: String]? {
        return data["signatures"] as? [String: String] ?? nil
    }
}
