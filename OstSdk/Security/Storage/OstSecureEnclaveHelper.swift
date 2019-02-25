//
//  SecureEnclaveImpl.swift
//  SecureEnclaveTest
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

@available(iOS 10.3, *)
/// Class that interacts with secure enclave. This is only available for the devices that has secure enclave support
class OstSecureEnclaveHelper: OstBaseStorage {
    /// Private key tag string
    var privateKeyTag: String

    /// Initializer
    ///
    /// - Parameter tag: Private key tag
    init(tag: String) {
        self.privateKeyTag = tag
        super.init()
    }
    
    // MARK: - internal methods
    
    /// Encrypt data with secure enclave
    ///
    /// - Parameters:
    ///   - data: Data that needs to be encrypted
    ///   - privateKey: Secure enclave private key reference
    /// - Returns: Encrypted data
    /// - Throws: OSTError
    func encrypt(data: Data, withPrivateKey privateKey: SecKey) throws -> Data {
        guard let publicKey = getPublicKeyFor(privateKey) else {
            throw OstError.init("s_s_seh_e_1", .unableToGetPublicKey)
        }
        return try _encrypt(data, publicKey: publicKey)
    }
    
    /// Decrypt the data with secure enclave
    ///
    /// - Parameters:
    ///   - data: Data that needs to be decrypted
    ///   - privateKey: Secure enclave private key reference
    /// - Returns: Decrypted data
    /// - Throws: OSTError
    func decrypt(data: Data, withPrivateKey privateKey: SecKey) throws -> Data {
        return try _decrypt(data, privateKey: privateKey)
    }
    
    /// Get private key. If the key does not exist in keychain, then creates a new one
    ///
    /// - Returns: SecKey, secure enclave private key reference
    /// - Throws: OSTError
    func getPrivateKey() throws -> SecKey? {
        guard let privateKey = getPrivateKeyFromKeychain() else {
            let privateKey = try generatePrivateKey()
            try storePrivateKeyInKeychain(privateKey)
            return getPrivateKeyFromKeychain()
        }
        return privateKey
    }

    /// Get the secure enclave private key reference form keychain
    ///
    /// - Returns: SecKey, secure enclave private key reference
    func getPrivateKeyFromKeychain() -> SecKey? {
        let query: [String: Any] = getPrivateKeyQuery()
        let item: CFTypeRef? = super.getFromKeychain(query);
        if (item == nil) {
            return nil
        }
        return (item as! SecKey)
    }
    
    /// Delete the secure enclave private key reference form keychain
    ///
    /// - Throws: OSTError
    func removePrivateKey() throws {
        let query: [String: Any] = getPrivateKeyQuery();
        try super.deleteFromKeyChain(query)
    }

    // MARK: - fileprivate methods
    
    /// Create a new secure enclave private key reference
    ///
    /// - Returns: SecKey, secure enclave private key reference
    /// - Throws: OSTError
    fileprivate func generatePrivateKey() throws -> SecKey {
        let accessControl = try getAccessControl()
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom as String,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: self.privateKeyTag,
                kSecAttrAccessControl as String: accessControl
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            Logger.log(message: "Error while generating private key.")
            throw OstError.init("s_s_seh_gpk_1", .generatePrivateKeyFail)
        }
        return privateKey
    }
    
    /// Store the secure enclave private key reference in keychain
    ///
    /// - Parameter privateKey: Secure enclave private key reference
    /// - Throws: OSTError
    fileprivate func storePrivateKeyInKeychain(_ privateKey: SecKey) throws {
        let tag = self.privateKeyTag.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecValueRef as String: privateKey]
        try super.setInKeychain(query);
    }
    
    /// Get public key
    ///
    /// - Parameter privateKey: Secure enclave private key reference
    /// - Returns: Public key
    fileprivate func getPublicKeyFor(_ privateKey: SecKey) -> SecKey? {
        return SecKeyCopyPublicKey(privateKey)
    }

    /// Build the private key's keychain query
    ///
    /// - Returns: Dictionary representing the keychain query
    fileprivate func getPrivateKeyQuery() -> [String: Any] {
        let tag = self.privateKeyTag.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom as String,
                                    kSecReturnRef as String: true]
        return query;
    }

    /// Encrypt data with secure enclave
    ///
    /// - Parameters:
    ///   - data: Data that needs to be encrypted
    ///   - privateKey: Secure enclave private key reference
    /// - Returns: Encrypted data
    /// - Throws: OSTError
    fileprivate func _encrypt(_ data: Data, publicKey: SecKey) throws -> Data {
        var error : Unmanaged<CFError>?
        
        let result = SecKeyCreateEncryptedData(publicKey,
                                               SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM,
                                               data as CFData,
                                               &error)
        if result == nil {
            Logger.log(message: "Error while encrypting data with public key.")
            throw OstError.init("s_s_seh_e1_1", .encryptFail)
        }
        return result! as Data
    }
    
    /// Decrypt the data with secure enclave
    ///
    /// - Parameters:
    ///   - data: Data that needs to be decrypted
    ///   - privateKey: Secure enclave private key reference
    /// - Returns: Decrypted data
    /// - Throws: OSTError
    fileprivate func _decrypt(_ data: Data, privateKey: SecKey) throws -> Data {
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(privateKey,
                                               SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM,
                                               data as CFData,
                                               &error)
        if result == nil {
            Logger.log(message: "Error while decrypting data with private key.")
            throw OstError.init("s_s_seh_d1_1", .decryptFail)
        }
        return result! as Data
    }
}
