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
    
    enum Status: String {
        case CREATED = "CREATED"
        case ACTIVATED = "ACTIVATED"
        case ACTIVATING = "ACTIVATING"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstUser
    }
    
    public class func getById(_ userId: String) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.getById(userId) as? OstUser
    }

    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstUser.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstUser.OSTUSER_PARENTID] as Any?)
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
    
    public func getCurrentDevice() -> OstCurrentDevice? {
        //TODO: - remvoe this code and get Deepesh code.
//        if (self.currentDevice != nil && !self.currentDevice!.isStatusCreated) {
//            return self.currentDevice
//        }
        
        let deviceAddress = OstKeyManager(userId: self.id).getDeviceAddress()
        if deviceAddress == nil {
            return nil
        }
        
        let device: OstDevice? = try! OstDeviceRepository.sharedDevice.getById(deviceAddress!) as? OstDevice
        if (device == nil) {
            return nil
        }
        //TODO: - remvoe this code and get Deepesh code.
//        if (self.currentDevice != nil) {
//            self.currentDevice?.data = device!.data as [String : Any]
//        } else {
//            self.currentDevice = try! OstCurrentDevice(device!.data as [String : Any])
//        }
        return try! OstCurrentDevice(device!.data as [String : Any])
    }
}

public extension OstUser {
    /// Get name.
    var name: String? {
        if let loName = data["name"] as? String {
            return loName.isEmpty ? nil : loName
        }
        return nil
    }
    
    /// Get token holder address.
    var tokenHolderAddress: String? {
        if let thAddress = data["token_holder_address"] as? String {
            return thAddress.isEmpty ? nil : thAddress
        }
        return nil
    }
    
    /// Get device manager address.
    var deviceManagerAddress: String? {
        if let dmAddress = data["device_manager_address"] as? String {
            return dmAddress.isEmpty ? nil : dmAddress
        }
        return nil
    }
    
    /// Get recovery address.
    var recoveryAddress: String? {
        if let rAddress = data["recovery_owner_address"] as? String {
            return rAddress.isEmpty ? nil : rAddress
        }
        return nil
    }
    
    /// Get token id.
    var tokenId: String? {
        return  OstUtils.toString(data["token_id"] as Any?)
    }
}

//MARK: - Status Checks
public extension OstUser {
    
    /// Check whether user status is CREATED or not. returns true if status is CREATED.
    var isStatusCreated: Bool {
        if let status: String = self.status {
            return (OstUser.Status.CREATED.rawValue == status)
        }
        return false
    }
    
    /// Check whether user status is ACTIVATED or not. returns true if status is ACTIVATED.
    var isStatusActivated: Bool {
        if let status: String = self.status {
            return (OstUser.Status.ACTIVATED.rawValue == status)
        }
        return false
    }
    
    /// Check whether user status is ACTIVATING or not. returns true if status is ACTIVATING.
    var isStatusActivating: Bool {
        if let status: String = self.status {
            return (OstUser.Status.ACTIVATING.rawValue == status)
        }
        return false
    }
}
