//
//  OstUserEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstUser: OstBaseEntity {
    
    static var tokenId: String = ""
    static var currentDevice: OstCurrentDevice? = nil

    static let OSTUSER_PARENTID = "token_id"
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstUser
    }

    public func getDeviceManager() throws -> OstDeviceManager? {
        if (self.multisig_id != nil) {
            return try OstDeviceManagerRepository.sharedDeviceManager.getById(self.multisig_id!) as? OstDeviceManager
        }
        return nil
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstUser.getEntityIdentiferKey()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstUser.OSTUSER_PARENTID])
    }
    
    override func processJson(_ entityData: [String : Any?]) {
        super.processJson(entityData)
        OstUser.tokenId = self.token_id!
    }
    
    func hasCurrentDevice() -> Bool {
        if let _ = getCurrentDevice() {
            return true
        }
        return false
    }
    
    func getCurrentDevice() -> OstCurrentDevice? {
        
        if (OstUser.currentDevice != nil) {
            return OstUser.currentDevice
        }
        
        let devices: [OstDevice] = try! OstDeviceRepository.sharedDevice.getByParentId(self.id) as! [OstDevice]
        let keyManager = try! OstKeyManager(userId: self.id)
        for device in devices {
            if let address = device.address {
                let isAddressValid = keyManager.hasAddresss(address)
                if isAddressValid {
                    do {
                        OstUser.currentDevice = try OstCurrentDevice(device.data as [String : Any])
                        return OstUser.currentDevice
                    }catch { }
                }
            }
        }
        return nil
    }
}

public extension OstUser {
    var name: String? {
        return data["name"] as? String ?? nil
    }
    
    var token_holder_id: String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var multisig_id: String? {
        return data["multisig_id"] as? String ?? nil
    }
    
    var token_id: String? {
        return data["token_id"] as? String ?? nil
    }
}
