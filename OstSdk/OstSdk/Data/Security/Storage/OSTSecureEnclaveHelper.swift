//
//  SecureEnclaveImpl.swift
//  SecureEnclaveTest
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

enum OSTSecureEnclaveError: Error {
    case invalidData
}

@available(iOS 10.3, *)
class OSTSecureEnclaveHelper {
    
    var address: String
    
    init(address: String) {
        self.address = address
    }
    
    // MARK: - Public methods
    
    func encrypt(data: Data) throws -> Data {
        guard let privateKey = try getPrivateKey() else {
            throw OSTSecureEnclaveError.invalidData
        }
        
        guard let publicKey = getPublicKeyFor(privateKey) else {
            throw OSTSecureEnclaveError.invalidData
        }
        return try _encrypt(data, publicKey: publicKey)
    }
    
    fileprivate func getPrivateKey() throws -> SecKey? {
        
        guard let privateKey = _getPrivateKey() else {
            
            let privateKey = try generatePrivateKey(getAccessControl())
            try forceStorePrivateKey(privateKey)
            return _getPrivateKey()
        }
        
        return privateKey
    }
    
    func decrypt(data: Data) throws -> Data{
        guard let privateKey = _getPrivateKey() else {
            throw OSTSecureEnclaveError.invalidData
        }
        return try _decrypt(data, privateKey: privateKey)
    }
    
    func deletePrivateKey() throws {
        let tag = "\(namespace).\(address)".data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
                                    kSecReturnRef as String: true]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw OSTSecureEnclaveError.invalidData
        }
    }
    
    // MARK: - fileprivate methods
    
    fileprivate var attrKeyTypeEllipticCurve: String {
        return kSecAttrKeyTypeECSECPrimeRandom as String
    }
    
    fileprivate var namespace: String {
        let bundle: Bundle = Bundle(for: type(of: self))
        let namespace = bundle.infoDictionary!["CFBundleIdentifier"] as! String;
        return namespace
    }
    
    fileprivate func getAccessControl() -> SecAccessControl {
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            .privateKeyUsage,
                                            nil)!
        
        return access
    }
    
    fileprivate func generatePrivateKey(_ access: SecAccessControl) throws -> SecKey {
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String:            attrKeyTypeEllipticCurve,
            kSecAttrKeySizeInBits as String:      256,
            kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String:      true,
                kSecAttrApplicationTag as String:   "\(namespace).\(address)",
                kSecAttrAccessControl as String:    access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print(error!)
            throw OSTSecureEnclaveError.invalidData
        }
        return privateKey
    }
    
    fileprivate func forceStorePrivateKey(_ privateKey: SecKey) throws {
        
        let tag = "\(namespace).\(address)".data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecValueRef as String: privateKey]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            print("value not stored in keychain for kSecAttrAccount: \(address)")
            throw OSTSecureEnclaveError.invalidData
        }
    }
    
    fileprivate func _getPrivateKey() -> SecKey? {
        let tag = "\(namespace).\(address)".data(using: .utf8)!
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
                                       kSecReturnRef as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard item != nil || status != errSecItemNotFound || status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    fileprivate func getPublicKeyFor(_ privateKey: SecKey) -> SecKey? {
        return SecKeyCopyPublicKey(privateKey)
    }
    
    fileprivate func _encrypt(_ data: Data, publicKey: SecKey) throws -> Data {
        
        var error : Unmanaged<CFError>?
        
        let result = SecKeyCreateEncryptedData(publicKey, SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM, data as CFData, &error)
        
        if result == nil {
            print(error!)
            throw OSTSecureEnclaveError.invalidData
        }
        
        return result! as Data
    }
    
    fileprivate func _decrypt(_ data: Data, privateKey: SecKey) throws -> Data {
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(privateKey, SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM, data as CFData, &error)
        if result == nil {
            print(error!)
            throw OSTSecureEnclaveError.invalidData
        }
        return result! as Data
    }
}
