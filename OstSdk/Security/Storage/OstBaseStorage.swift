//
//  OstBaseStorage.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// OSTBaseStorage is a base class that provides the functionality to interact with keychain.
class OstBaseStorage {
    /// Initializer
    init() { }
    
    /// Get accress control for secure enclave
    ///
    /// - Returns: SecAccessControl
    /// - Throws: OSTError
    func getAccessControl(controlFlag: SecAccessControlCreateFlags) throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     controlFlag,
                                                     &error)!
        
        
        if (error != nil) {
            throw OstError1("s_s_bs_gac_1", .accessControlFailed);
        }
        return access
    }
    
    func getSecAccessControlCreateFlags() -> SecAccessControlCreateFlags {
        fatalError("getSecAccessControlCreateFlags")
    }
    
    /// Function to set item in the keychain
    ///
    /// - Parameter query: Keychain query dictionary
    /// - Throws: OSTError
    func setInKeychain(_ query: [String: Any]) throws {
        var status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess else {
                Logger.log(message: "Error while deleting from keychain.")
                throw OstError1.init("s_s_bs_hs_1", .keychainDeleteItemFail)
            }
            status = SecItemAdd(query as CFDictionary, nil)
        }
        guard status == errSecSuccess else {
            Logger.log(message: "Error while adding item in keychain.")
            throw OstError1.init("s_s_bs_hs_2", .keychainAddItemFail)
        }
    }
    
    /// Function to get items from keychain
    ///
    /// - Parameter query: Keychain query dictionary
    /// - Returns: CFTypeRef if available otherwise nil
    func getFromKeychain(_ query: [String: Any]) -> CFTypeRef? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            Logger.log(message: "No item found in keychain.")
            return nil
        }
        return item
    }
    
    /// Function to delete the item for keychain
    ///
    /// - Parameter query: Keychain query dictionary
    /// - Throws: OSTError
    func deleteFromKeyChain(_ query: [String: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            Logger.log(message: "Error while deleting item from keychain.")
            throw OstError1.init("s_s_bs_dfkc_1", .keychainDeleteItemFail)
        }
    }
}
