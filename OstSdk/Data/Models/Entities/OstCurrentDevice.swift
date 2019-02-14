//
//  OstCurrentDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSessionKeyInfo {
    var sessionKeyData: Data
    var isSecureEnclaveEncrypted: Bool
    
    init(sessionKeyData: Data, isSecureEnclaveEncrypted: Bool = false) {
        self.sessionKeyData = sessionKeyData
        self.isSecureEnclaveEncrypted = isSecureEnclaveEncrypted
    }
    
    func toDictionary() -> [String: Any] {
        return ["sessionKeyData": sessionKeyData,
                "isSecureEnclaveEncrypted": isSecureEnclaveEncrypted]
    }
}

class OstCurrentDevice: OstDevice {
    override init(_ params: [String : Any]) throws {
        try super.init(params)
    }
    
    func encrypt(privateKey: String) throws -> OstSessionKeyInfo {
        let privateKeyData = privateKey.data(using: .utf8)!
        
        if let ethMetaMapping: EthMetaMapping = try OstKeyManager(userId: self.userId!).getEthKeyMetaMapping(forAddress: self.address!) {
                let enclaveIdentifier = ethMetaMapping.identifier
                if #available(iOS 10.3, *) {
                    let enclaveHelper = OstSecureEnclaveHelper(tag: enclaveIdentifier)
                    
                    if let enclavePrivateKey: SecKey = try enclaveHelper.getPrivateKey() {
                        let encData = try enclaveHelper.encrypt(data: privateKeyData, withPrivateKey: enclavePrivateKey)
                        return OstSessionKeyInfo(sessionKeyData: encData, isSecureEnclaveEncrypted: true)
                    }
                }
        }
        return OstSessionKeyInfo(sessionKeyData: privateKeyData, isSecureEnclaveEncrypted: false)
    }
    
    func decrypt(sessionKeyInfo: OstSessionKeyInfo) throws -> String {
        var decData = sessionKeyInfo.sessionKeyData
        
        if (sessionKeyInfo.isSecureEnclaveEncrypted) {
            if let ethMetaMapping: EthMetaMapping = try OstKeyManager(userId: self.userId!).getEthKeyMetaMapping(forAddress: self.address!) {
                    let enclaveIdentifier = ethMetaMapping.identifier
                    if #available(iOS 10.3, *) {
                        let enclaveHelper = OstSecureEnclaveHelper(tag: enclaveIdentifier)
                        if let enclavePrivateKey: SecKey = try enclaveHelper.getPrivateKey() {
                            decData = try enclaveHelper.decrypt(data: decData, withPrivateKey: enclavePrivateKey)
                        }
                    }
            }
        }
        return String(data: decData, encoding: .utf8)!
    }
    
    func isDeviceRegistered() -> Bool {
        let status = self.status
        if (status == nil) {
            return false
        }
        
        return ["REGISTERED", "AUTHORIZED", "AUTHORIZING"].contains(status!)
    }
    
    func isDeviceRevoked() -> Bool {
        let status = self.status
        if (status == nil) {
            return true
        }
        
        return ["REVOKING", "REVOKED"].contains(status!)
    }
    
    func isCreated() -> Bool {
        let status = self.status
        if (status != nil &&
            status! == "CREATED") {
            return true
        }
        return false
    }
}
