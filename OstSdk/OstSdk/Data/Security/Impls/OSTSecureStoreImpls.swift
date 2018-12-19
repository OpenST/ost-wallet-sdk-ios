//
//  OstSdkSecureStoreImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTSecureStoreImpls: OSTSecureStore {
    
    private var keyAlias = ""
    
    public init(keyAlias: String) throws {
        self.keyAlias = keyAlias
//        try generateKeys()
    }
    
    func generateKeys() throws {
        if #available(iOS 10.0, *) {
            try storeKeyInSecureEnclave()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 10.0, *)
    func storeKeyInSecureEnclave() throws {
        let access = getAccess()
        let attributes = getAttributes(access)
        try createKeys(attributes: attributes)
    }
    
    func getAccess() -> SecAccessControl {
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleAlways,
                                            .privateKeyUsage,
                                            nil)!
        return access
    }
    
    @available(iOS 10.0, *)
    func getAttributes(_ access: SecAccessControl) -> [String: Any] {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String:      256,
//            kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String:      true,
                kSecAttrApplicationTag as String:   self.keyAlias,
                kSecAttrAccessControl as String:    access
            ]
        ]
        return attributes
    }
    
    @available(iOS 10.0, *)
    func createKeys(attributes: [String: Any]) throws {
        var error: Unmanaged<CFError>?
        guard let _ = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
    }
    
    
    public func encrypt(data: [UInt8]) {
        
    }
    
    public func decrypt(data: [UInt8]) {
        
    }
    
    @available(iOS 10.0, *)
    func test() throws {
        let tag = "com.example.keys.mykey"
        let attributes: [String: Any] =
            [kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
             kSecAttrKeySizeInBits as String:      256,
             kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String:      true,
                 kSecAttrApplicationTag as String: tag]
        ]
        
        var error: Unmanaged<CFError>?
        guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
            throw error!.takeRetainedValue() as Error
        }

    }
    
    public func storeData(_ data: Data,forKey key: String) throws {
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                            .userPresence, nil)
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: "com.OstSdK",
                                    kSecAttrAccessControl as String: accessControl as Any,
                                    kSecValueData as String: data]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("value not stored in keychain for kSecAttrAccount: \(key)")
            throw "Error" as! Error
        }
    }
    
    func getDataFor(key: String) -> Any {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: "com.OstSdK",
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        guard let existingItem =  get(query: query) as? [String: Any],
            let data = existingItem[kSecValueData as String] else {
                print("getDataFromKeychain : Key is not available in keychain")
                return ""
        }
        return data
    }
    
    func get(query: [String: Any]) -> CFTypeRef? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            return nil
        }
        return item
    }
    
}
