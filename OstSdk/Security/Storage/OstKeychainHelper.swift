//
//  OstKeychainImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// Class that interacts with keychain
class OstKeychainHelper: OstBaseStorage {
    /// Keychain service string
    var service: String
    
    /// Initializer
    ///
    /// - Parameter service: Keychain service string
    public init(service: String) {
        self.service = service
        super.init()
    }
    
    //MARK: - Store in keychain
    
    /// Store data in keychain
    ///
    /// - Parameters:
    ///   - data: Data that needs to be stored in keychain
    ///   - key: Key against which the data will be stored
    /// - Throws: OSTError
    func setDataInKeychain(data: Data, forKey key: String) throws {
        let accessControl = try getAccessControl();
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: self.service,
                                    kSecAttrAccessControl as String: accessControl,
                                    kSecValueData as String: data]
        
        try super.setInKeychain(query);
    }
    
    /// Store string in keychain
    ///
    /// - Parameters:
    ///   - string: String that needs to be stored in keychain
    ///   - key: Key against which the data will be stored
    /// - Throws: OSTError
    func setStringInKeychain(string: String, forKey key: String) throws {
        let data: Data = string.data(using: .utf8)!
        try setDataInKeychain(data: data, forKey: key)
    }
    
    //MARK: - Get from keychain
    
    /// Get data from keychain
    ///
    /// - Parameter key: Key to lookup in keychain
    /// - Returns: Data if exists otherwise nil
    func getDataFromKeychain(forKey key: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: self.service,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        let item: CFTypeRef? = super.getFromKeychain(query);
        
        if let existingItem =  item as? [String: Any],
            let data = existingItem[kSecValueData as String] as? Data {
            return data
        }
        return nil
    }
    
    /// Get string from keychain
    ///
    /// - Parameter key: Key to lookup in keychain
    /// - Returns: String if exists otherwise nil
    func getStringFromKeychain(forKey key: String) -> String? {
        if let data: Data = getDataFromKeychain(forKey: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    //MARK: - Delete from keychain
    
    /// Delete item from keychain
    ///
    /// - Parameter key: Key to lookup in keychain
    /// - Throws: OSTError
    func deleteFromKeychain(forKey key: String) throws {
        let accessControl = try getAccessControl();
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: self.service,
                                    kSecAttrAccessControl as String: accessControl]
        try super.deleteFromKeyChain(query)
    }
}
