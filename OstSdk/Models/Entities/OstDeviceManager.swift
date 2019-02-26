//
//  OstDeviceManagerEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstDeviceManager: OstBaseEntity {
    
    static let OSTDEVICE_MANAGER_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstDeviceManager? {
        return try OstDeviceManagerRepository.sharedDeviceManager.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstDeviceManager
    }
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    class func getById(_ address: String) throws -> OstDeviceManager? {
        return try OstDeviceManagerRepository.sharedDeviceManager.getById(address) as? OstDeviceManager
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstDeviceManager.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstDeviceManager.OSTDEVICE_MANAGER_PARENTID] as Any?)
    }
    
    public func getDeviceMultiSigWallet() throws -> OstDevice? {
        do {
            guard let multiSigWallets: [OstDevice] = try OstDeviceRepository.sharedDevice.getByParentId(self.id) as? [OstDevice] else {
                return nil
            }
            
            for multiSigWallet in multiSigWallets {
                guard let multiSigWalletAddress: String = multiSigWallet.address else {
                    continue
                }
                guard let _: OstSecureKey = try OstSecureKeyRepository.sharedSecureKey.getById(multiSigWalletAddress) as? OstSecureKey else {
                    continue
                }
                return multiSigWallet
            }
        }catch let error {
            throw error
        }
        
        return nil
    }
    
    func incrementAndUpdateNonce(_ nonce: Int) throws {
        var updatedData: [String: Any?] = self.data
        updatedData["nonce"] = OstUtils.toString(nonce+1)
        updatedData["updated_timestamp"] = OstUtils.toString(Date.timestamp())
        _ = try OstDeviceManager.parse(updatedData)
    }
}

public extension OstDeviceManager {
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var nonce: Int {
        return OstUtils.toInt(data["nonce"] as Any?) ?? 0
    }
    
    var token_holder_id : String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var wallets : Array<String>? {
        return data["wallets"] as? Array<String> ?? nil
    }
    
    var requirement: String? {
        return data["requirement"] as? String ?? nil
    }
    
    var authorize_session_callprefix: String? {
        return data["authorize_session_callprefix"] as? String ?? nil
    }
}
