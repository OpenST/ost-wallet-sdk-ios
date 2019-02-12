//
//  OstUserEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstUser: OstBaseEntity {
    
    var currentDevice: OstCurrentDevice? = nil

    static let OSTUSER_PARENTID = "token_id"
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstUser
    }

    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstUser.getEntityIdentiferKey()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstUser.OSTUSER_PARENTID])
    }
    
    override func processJson(_ entityData: [String : Any?]) {
        super.processJson(entityData)
    }
    
    func hasCurrentDevice() -> Bool {
        if let _ = getCurrentDevice() {
            return true
        }
        return false
    }
    
    func getCurrentDevice() -> OstCurrentDevice? {
        if (self.currentDevice != nil) {
            return self.currentDevice
        }
        
        let deviceAddress = try! OstKeyManager(userId: id).getDeviceAddress()
        if deviceAddress == nil {
            return nil
        }
        
        let device: OstDevice? = try! OstDeviceRepository.sharedDevice.getById(deviceAddress!) as? OstDevice
        if (device == nil) {
            return nil
        }
        self.currentDevice = try! OstCurrentDevice(device!.data as [String : Any])
        return self.currentDevice
    }
}

public extension OstUser {
    var name: String? {
        if let loName = data["name"] as? String {
            return loName.isEmpty ? nil : loName
        }
        return nil
    }
    
    var tokenHolderAddress: String? {
        if let thAddress = data["token_holder_address"] as? String {
            return thAddress.isEmpty ? nil : thAddress
        }
        return nil
    }
    
    var deviceManagerAddress: String? {
        if let dmAddress = data["device_manager_address"] as? String {
            return dmAddress.isEmpty ? nil : dmAddress
        }
        return nil
    }
    
    var tokenId: String? {
        return data["token_id"] as? String ?? nil
    }
}
