//
//  SecureEnclaveImpl.swift
//  SecureEnclaveTest
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

enum OstSecureEnclaveError: Error {
    case invalidData
}

@available(iOS 10.3, *)
public class OstSecureEnclaveHelper: OstBaseStorage {
    
    var privateKeyTag: String
    
    fileprivate var attrKeyTypeEllipticCurve: String {
        return kSecAttrKeyTypeECSECPrimeRandom as String
    }
    
    init(tag: String) {
        self.privateKeyTag = tag
        super.init()
    }
    
    // MARK: - Public methods
    
    func encrypt(data: Data) throws -> Data {
        guard let privateKey = try getPrivateKey() else {
            throw OstSecureEnclaveError.invalidData
        }
        
        guard let publicKey = getPublicKeyFor(privateKey) else {
            throw OstSecureEnclaveError.invalidData
        }
        return try _encrypt(data, publicKey: publicKey)
    }
    
    func decrypt(data: Data) throws -> Data {
        guard let privateKey = get() else {
            throw OstSecureEnclaveError.invalidData
        }
        return try _decrypt(data, privateKey: privateKey)
    }
    
    func remove() throws {
        let tag = privateKeyTag.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
                                    kSecReturnRef as String: true]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw OstSecureEnclaveError.invalidData
        }
    }

    // MARK: - fileprivate methods
    
    fileprivate func getPrivateKey() throws -> SecKey? {
        guard let privateKey = get() else {
            let accessControl = getAccessControl()
            let privateKey = try generatePrivateKey(accessControl)
            try hardSet(privateKey)
            return get()
        }
        
        return privateKey
    }
    
    fileprivate func generatePrivateKey(_ accessControl: SecAccessControl) throws -> SecKey {
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String:            attrKeyTypeEllipticCurve,
            kSecAttrKeySizeInBits as String:      256,
            kSecAttrTokenID as String:            kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String:      true,
                kSecAttrApplicationTag as String:   privateKeyTag,
                kSecAttrAccessControl as String:    accessControl
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print(error!)
            throw OstSecureEnclaveError.invalidData
        }
        return privateKey
    }
    
    fileprivate func hardSet(_ privateKey: SecKey) throws {
        
        let tag = privateKeyTag.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecValueRef as String: privateKey]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            print("value not stored in keychain for kSecAttrAccount: \(privateKeyTag)")
            throw OstSecureEnclaveError.invalidData
        }
    }
    
    fileprivate func get() -> SecKey? {
        let tag = privateKeyTag.data(using: .utf8)!
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
            throw OstSecureEnclaveError.invalidData
        }
        
        return result! as Data
    }
    
    fileprivate func _decrypt(_ data: Data, privateKey: SecKey) throws -> Data {
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(privateKey, SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM, data as CFData, &error)
        if result == nil {
            print(error!)
            throw OstSecureEnclaveError.invalidData
        }
        return result! as Data
    }
}
