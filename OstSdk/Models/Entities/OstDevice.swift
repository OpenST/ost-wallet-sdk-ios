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
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstDevice.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstDevice.OSTDEVICE_PARENTID] as Any?)
    }
    
    public func isDeviceRegistered() -> Bool {
        let status = self.status
        if (status == nil) {
            return false
        }
        
        return ["REGISTERED", "AUTHORIZING", "AUTHORIZED"].contains(status!)
    }
    
    public func isAuthorizing() -> Bool {
        let status = self.status
        if (status != nil &&
            status! == "AUTHORIZING") {
            return true
        }
        return false
    }

  public func isAuthorized() -> Bool {
    let status = self.status
    if (nil != status &&
      "AUTHORIZED" == status!) {
      return true
    }
    return false
  }

  
    public  func isDeviceRevoked() -> Bool {
        let status = self.status
        if (status == nil) {
            return true
        }
        
        return ["REVOKING", "REVOKED"].contains(status!)
    }
    
    public  func isCreated() -> Bool {
        let status = self.status
        if (status != nil &&
            status! == "CREATED") {
            return true
        }
        return false
    }
}

public extension OstDevice {
    var local_entity_id: String? {
        return data["local_entity_id"] as? String 
    }
    
    var address: String? {
        return data["address"] as? String
    }
    
    var api_signer_address: String? {
        return data["api_signer_address"] as? String
    }
    
    var multi_sig_id: String? {
        return data["multi_sig_id"] as? String
    }
    
    var userId: String? {
        return data["user_id"] as? String
    }
    
    var device_manager_address: String? {
        return data["device_manager_address"] as? String
    }
}
