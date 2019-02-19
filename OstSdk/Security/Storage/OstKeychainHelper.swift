//
//  OstKeychainImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstKeychainHelper: OstBaseStorage {
    
    var service: String
    
    public init(service: String) {
        self.service = service
        super.init()
    }
    
    //MARK: - Keychain Data
    public func hardSet(data: Data, forKey key: String) throws {
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: service,
                                    kSecAttrAccessControl as String: getAccessControl() as Any,
                                    kSecValueData as String: data]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw OstError.actionFailed("storing data failed")
        }
    }
    
    public func get(forKey key: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: service,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else { return nil }
        
        if let existingItem =  item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data {
            return data
        }
        return nil
    }
    
    //MARK: - Keychain String
    public func set(string: String, forKey key: String) throws {
        let data: Data = string.data(using: .utf8)!
        try hardSet(data: data, forKey: key)
    }
    
    public func get(forKey key: String) -> String? {
        if let data: Data = get(forKey: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    public func delete(forKey key: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: service,
                                    kSecAttrAccessControl as String: getAccessControl() as Any]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw OstError.actionFailed("Delete failed")
        }
    }
}
