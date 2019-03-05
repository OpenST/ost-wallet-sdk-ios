//
//  OstSdkSecureStoreImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import LocalAuthentication
import CryptoSwift
import EthereumKit

let SERVICE_NAME = "com.ost"
let ETHEREUM_KEY_PREFIX = "Ethereum_key_for_"
let MNEMONICS_KEY_PREFIX = "Mnemonics_for_"
let SESSION_KEY_PREFIX = "Session_key_for_"
let SECURE_ENCLAVE_KEY_PREFIX = "secure_enclave_identifier_"
let USER_DEVICE_KEY_PREFIX = "user_device_info_for_"
let ETH_META_MAPPING_KEY = "EthKeyMetaMapping"
let MNEMONICS_META_MAPPING_KEY = "EthKeyMnemonicsMetaMapping"
let SESSION_META_MAPPING_KEY = "SessionKeyMetaMapping"
let API_ADDRESS_KEY = "api_address"
let DEVICE_ADDRESS_KEY = "device_address"
let RECOVERY_PIN_HASH = "recovery_pin_hash"

public struct EthMetaMapping {
    /// Ethererum address
    var address: String
    
    /// Entity id to look up the private key of the ethereum address in keychain
    var entityId: String
    
    /// Secure enclave reference key
    var identifier: String
    
    /// Boolean to indicate if secure enclave is used to encrypt the data
    var isSecureEnclaveEncrypted: Bool

    /// Initializer for EthMetaMapping.
    ///
    /// - Parameters:
    ///   - address: Ethereum key
    ///   - entityId: Keychain item identifier
    ///   - identifier: Secure enclave key identifier
    ///   - isSecureEnclaveEncrypted: A boolean to indicate if secure enclave encrption is used for storing data
    init(address: String, entityId: String, identifier: String = "", isSecureEnclaveEncrypted: Bool = false) {
        self.address = address
        self.entityId = entityId
        self.identifier = identifier
        self.isSecureEnclaveEncrypted = isSecureEnclaveEncrypted
    }
    
    /// Converts the EthMetaMapping data in to dictionary format
    ///
    /// - Returns: [String: Any] dictionary
    func toDictionary() -> [String: Any] {
        let dict: [String : Any] = ["entityId": self.entityId,
                                    "address": self.address,
                                    "identifier": self.identifier,
                                    "isSecureEnclaveEncrypted": self.isSecureEnclaveEncrypted]
        return dict
    }
    
    /// Get EthMetaMapping object from Dictionary
    ///
    /// - Parameter dictionary: Dictionary containing eth meta mapping values
    /// - Returns: EthMetaMapping object
    static func getEthMetaMapping(from dictionary:[String: Any]) -> EthMetaMapping {
        let ethMetaMappingObj = EthMetaMapping(
            address: dictionary["address"] as! String,
            entityId: dictionary["entityId"] as! String,
            identifier: dictionary["identifier"] as! String,
            isSecureEnclaveEncrypted: dictionary["isSecureEnclaveEncrypted"] as! Bool
        );
        return ethMetaMappingObj
    }
}

/// Class for managing the ethereum keys.
// TODO: make this internal
public class OstKeyManager {
    typealias SignedData = (address: String, signature: String)
    
    // MARK: - Instance varaibles
    
    /// Helper object to interact with keychain
    private var keychainHelper: OstKeychainHelper
    
    /// Current user id
    private var userId: String
    
    /// Secure enclave identifier key
    private var secureEnclaveIdentifier: String
    
    /// Current user's device info
    private var currentUserDeviceInfo: [String: Any]? = nil
    
    // MARK: - Initializers
    
    /// Class initializer
    ///
    /// - Parameter userId: User id whose keys will be managed.
    init (userId: String) {
        self.userId = userId
        self.keychainHelper = OstKeychainHelper(service: SERVICE_NAME)
        self.secureEnclaveIdentifier = OstKeyManager.getSecureEnclaveKey(forUserId: userId)
    }
    
    //MARK: - API key

    /// Function to create API address and key.
    /// The address and key are stored securely in the keychain.
    ///
    /// - Returns: API address
    /// - Throws: Exceptions that occurs while creating and storing the keys
    func createAPIKey() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateOstWalletKeys()
        if (ethKeys.privateKey == nil || ethKeys.address == nil) {
            throw OstError("s_i_km_cak_1", .generatePrivateKeyFail)
        }
        try storeEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try storeAPIAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    /// Store the API address in keychain
    ///
    /// - Parameter address: Ethereum address that needs to be stored
    /// - Throws: Exceptions that occurs while storing the address
    private func storeAPIAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo[API_ADDRESS_KEY] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Get the current users API address
    ///
    /// - Returns: API address
    func getAPIAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo[API_ADDRESS_KEY] as? String
    }
    
    /// Get the private key for the API address
    ///
    /// - Returns: Private key for the API address if available otherwise nil
    /// - Throws: Exception that occurs while getting the private key
    private func getAPIKey() throws -> String? {
        if let apiAddress = getAPIAddress() {
            return try getEthereumKey(forAddresss: apiAddress)
        }
        return nil
    }
    
    //MARK: - Device Key
    
    /// Create the device private key and address.
    /// This also stores the private key and address securly in the keychain
    ///
    /// - Returns: Device address
    /// - Throws: Exceptions that occurs while storing the address or key in the keychain
    func createDeviceKey() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateOstWalletKeys()
        if (ethKeys.privateKey == nil || ethKeys.address == nil) {
            throw OstError("s_i_km_cdk_1", .generatePrivateKeyFail)
        }
        try storeMnemonics(ethKeys.mnemonics!, forAddress: ethKeys.address!)
        try storeEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try storeDeviceAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    /// Store the device address in the keychain
    ///
    /// - Parameter address: Device address
    /// - Throws: Exception that occurs while storing the device address in keychain
    private func storeDeviceAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo[DEVICE_ADDRESS_KEY] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Get current user's stored device address from keychain
    ///
    /// - Returns: Device address if available otherwise nil
    func getDeviceAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo[DEVICE_ADDRESS_KEY] as? String
    }
    
    /// Get private key of current user's stored device address
    ///
    /// - Returns: Private key for device address if available otherwise nil
    /// - Throws: Exception that accurs while getting the private key from keychain
    private func getDeviceKey() throws -> String? {
        if let deviceAddress = getDeviceAddress() {
            return try getEthereumKey(forAddresss: deviceAddress)
        }
        return nil
    }
    
    /// Get the 12 words mnemonic keys for the current user's device address
    ///
    /// - Returns: JSON serialized 12 words mnemonics key
    /// - Throws: Exception that occurs while getting the keys from keychain
    func getDeviceMnemonics() throws -> [String]? {
        if let deviceAddress = getDeviceAddress() {
            if let ethMetaMapping: EthMetaMapping =  getMnemonicsMetaMapping(forAddress: deviceAddress) {
                if let jsonString: String = try getString(from: ethMetaMapping) {
                    return try OstUtils.toJSONObject(jsonString) as? [String]
                }
            }
        }
        return nil
    }
    
    //MARK: - Session Key
    
    /// Create the session private key and address.
    /// This also stores the private key and address securly in the keychain
    ///
    /// - Returns: Device address
    /// - Throws: Exceptions that occurs while storing the address or key in the keychain
    func createSessionKey() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateOstWalletKeys()
        if (ethKeys.privateKey == nil || ethKeys.address == nil) {
            throw OstError("s_i_km_csk_1", .generatePrivateKeyFail)
        }
        try storeSessionKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        return ethKeys.address!
    }
    
    /// Get all the session addresses available in the device
    ///
    /// - Returns: Array containing session addresses
    /// - Throws: OstError
    func getSessions() throws -> [String] {
        return getAllAddresses(ForKey: SESSION_META_MAPPING_KEY)
    }

    /// Delete session address and its key
    ///
    /// - Parameter sessionAddress: Session address
    /// - Throws: OstError
    func deleteSessionKey(sessionAddress: String) throws {
        try deleteMetaMapping(forAddress: sessionAddress, forKey: SESSION_META_MAPPING_KEY)
    }

    //MARK: - Recovery
    
    func getRecoveryOwnerAddressFrom(
        password: String,
        pin: String,
        salt: String) throws -> String {
        
        let recoveryOwnerAddress = try OstCryptoImpls().generateRecoveryKey(
            password: password,
            pin: pin,
            userId: self.userId,
            salt: salt,
            n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
            r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
            p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
            size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES
        )
        
        return recoveryOwnerAddress
    }
    
//    func generateRecoveryOwnerAddress(
//        password: String,
//        pin: String,
//        salt: String) throws -> String {
//        
//        let recoveryOwnerAddress = try self.getRecoveryOwnerAddressFrom(
//            password: password,
//            pin: pin,
//            salt: salt
//        )
//        
//        let recoveryPinHash = generateRecoveryPinHash(
//            password: password,
//            pin: pin,
//            salt: salt,
//            recoveryOwnerAddress: recoveryOwnerAddress
//        )
//
//        try storeRecoveryPinHash(recoveryPinHash)
//        
//        return recoveryOwnerAddress
//    }
    
    private func generateRecoveryPinHash(
        password: String,
        pin: String,
        salt: String,
        recoveryOwnerAddress: String) -> String {
        
        let rawString = "\(self.userId)\(password)\(pin)\(salt)\(recoveryOwnerAddress.lowercased())"
        let recoveryHash = rawString.sha3(.keccak256)
        return recoveryHash
    }
    //TODO: - Store data from keychain.
    /// Store recovery pin string in key chain
    ///
    /// - Parameter pinString: Pin string generated at the time of activate user.
    /// - Returns:  true if data stored in keychain successfully.
    private func storeRecoveryPinHash(_ recoveryPinHash: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        // TODO: add secure enclave encoding here for recoveryPinHash
        userDeviceInfo[RECOVERY_PIN_HASH] = OstUtils.toEncodedData(recoveryPinHash.data(using: .utf8)!)
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    func deletePin() throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo[RECOVERY_PIN_HASH] = nil
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    func verifyPin(
        password: String,
        pin: String,
        salt: String,
        recoveryOwnerAddress: String) -> Bool {
    
        var isValid = true
        
        let recoveryPinHash = generateRecoveryPinHash(
            password: password,
            pin: pin,
            salt: salt,
            recoveryOwnerAddress: recoveryOwnerAddress
        )
        
        do {
            try verifyRecoveryPinHash(recoveryPinHash)
        } catch {
            // Fallback
            if let generatedAddress = try? self.getRecoveryOwnerAddressFrom(
                    password: password,
                    pin: pin,
                    salt: salt
                )  {

                isValid = recoveryOwnerAddress.caseInsensitiveCompare(generatedAddress) ==  .orderedSame
                if isValid {
                    try? storeRecoveryPinHash(recoveryPinHash)
                }
            } else {
                isValid = false
            }                        
        }
        return isValid
    }
    /// Verify stored pin string with passed one.
    ///
    /// - Parameter pinString: Pin string generated at the time of activate user.
    /// - Returns: true if data stored in keychain successfully.
    private func verifyRecoveryPinHash(_ recoveryPinHash: String) throws {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        guard let hashEncodedData : Data = userDeviceInfo[RECOVERY_PIN_HASH] as? Data else {
            throw OstError("s_i_km_vrps_1", .recoveryPinNotFoundInKeyManager)
        }
        guard let hashData = OstUtils.toDecodedValue(hashEncodedData) as? Data else {
            throw OstError("s_i_km_vrps_2", .recoveryPinNotFoundInKeyManager)
        }
        let existingRecoveryPinHash = String(bytes: hashData, encoding: .utf8)!
        // TODO: add secure enclave encoding here for recoveryPinHash
        
        let isSucess = (recoveryPinHash.caseInsensitiveCompare(existingRecoveryPinHash) == .orderedSame )
        if !isSucess {
            throw OstError("s_i_km_vrps_3", .pinValidationFailed)
        }
    }
}

// MARK: - MetaMapping getters and setters
fileprivate extension OstKeyManager {
    /// Set the eth meta mapping in the keychain
    ///
    /// - Parameter ethMetaMapping: EthMetaMapping object that needs to be stored in keychain
    /// - Throws: Exception that occurs while setting the data in keychain
    func setEthKeyMetaMapping(_ ethMetaMapping: EthMetaMapping) throws {
        try setMetaMapping(ethMetaMapping, forKey: ETH_META_MAPPING_KEY)
    }
    
    /// Get the eth meta mapping object from the keychain
    ///
    /// - Parameter address: Ethereum address to lookup the EthMetaMapping object
    /// - Returns: EthMetaMapping object
    func getEthKeyMetaMapping(forAddress address: String) -> EthMetaMapping?  {
        return getMetaMapping(forAddress: address, andKey: ETH_META_MAPPING_KEY)
    }
    
    /// Set mnemonics meta mapping in the keychain
    ///
    /// - Parameter ethMetaMapping: EthMetaMapping object that needs to be stored in keychain
    /// - Throws: Exception that occurs while setting the data in keychain
    func setMnemonicsMetaMapping(_ ethMetaMapping: EthMetaMapping) throws {
        try setMetaMapping(ethMetaMapping, forKey: MNEMONICS_META_MAPPING_KEY)
    }
    
    /// Get the mnemonic meta mapping object from the keychain
    ///
    /// - Parameter address: Ethereum address to lookup the EthMetaMapping object
    /// - Returns: EthMetaMapping object
    func getMnemonicsMetaMapping(forAddress address: String) -> EthMetaMapping?  {
        return getMetaMapping(forAddress: address, andKey: MNEMONICS_META_MAPPING_KEY)
    }
    
    /// Set the session meta mapping in the keychain
    ///
    /// - Parameter ethMetaMapping: EthMetaMapping object that needs to be stored in keychain
    /// - Throws: Exception that occurs while setting the data in keychain
    func setSessionKeyMetaMapping(_ ethMetaMapping: EthMetaMapping) throws {
        try setMetaMapping(ethMetaMapping, forKey: SESSION_META_MAPPING_KEY)
    }
    
    /// Get the session meta mapping object from the keychain
    ///
    /// - Parameter address: Ethereum address to lookup the EthMetaMapping object
    /// - Returns: EthMetaMapping object
    func getSessionKeyMetaMapping(forAddress address: String) -> EthMetaMapping?  {
        return getMetaMapping(forAddress: address, andKey: SESSION_META_MAPPING_KEY)
    }
}

// MARK: - Lookup storage keys
fileprivate extension OstKeyManager {
    /// Get the storage key for user device info
    ///
    /// - Parameter userId: User id for key formation
    /// - Returns: Storage key for user device info
    static func getUserDeviceInfoStorageKey(forUserId userId:String) -> String {
        return "\(USER_DEVICE_KEY_PREFIX)\(userId)"
    }
    
    /// Get ethereum address storage key
    ///
    /// - Parameter address: Ethereum address for key formation
    /// - Returns: Storage key for ethereum address lookup
    static func getAddressStorageKey(forAddress address: String) -> String {
        return "\(ETHEREUM_KEY_PREFIX)\(address.lowercased())"
    }
    
    /// Get the storage key for mnemonics lookup
    ///
    /// - Parameter address: Ethereum address for key formation
    /// - Returns: Storage key for mnemonics lookup
    static func getMnemonicsStorageKey(forAddress address: String) -> String {
        return "\(MNEMONICS_KEY_PREFIX)\(address.lowercased())"
    }
    
    /// Get the storage key for session lookup
    ///
    /// - Parameter address: Ethereum address for key formation
    /// - Returns: Storage key for mnemonics lookup
    static func getSessionStorageKey(forAddress address: String) -> String {
        return "\(SESSION_KEY_PREFIX)\(address.lowercased())"
    }
    
    /// Get the key for secure enclave lookup
    ///
    /// - Parameter userId: User id for key formation
    /// - Returns: Key for secure enclave
    static func getSecureEnclaveKey(forUserId userId: String) -> String {
        return "\(SECURE_ENCLAVE_KEY_PREFIX)\(userId.lowercased())"
    }
    
    /// Get the storage key for current user device info
    ///
    /// - Returns: Storage key for user device info
    func getCurrentUserDeviceInfoStorageKey() -> String {
        return OstKeyManager.getUserDeviceInfoStorageKey(forUserId: self.userId);
    }
}

// MARK: - Private functions
private extension OstKeyManager {
    /// Get the user device info for the current user
    ///
    /// - Returns: User device info dictionary
    func getUserDeviceInfo() -> [String: Any] {
        if (currentUserDeviceInfo != nil) {
            return currentUserDeviceInfo!
        }
        if let userDevice: Data = keychainHelper.getDataFromKeychain(forKey: getCurrentUserDeviceInfoStorageKey()) {
            currentUserDeviceInfo = userDevice.toDictionary()
            return currentUserDeviceInfo!
        }
        return [:]
    }
    
    /// Set user device info for the current user
    ///
    /// - Parameter deviceInfo: Device info dictionary object
    /// - Throws: OSTError
    func setUserDeviceInfo(deviceInfo: [String: Any]) throws {
        currentUserDeviceInfo = deviceInfo
        let deviceInfoData = OstUtils.toEncodedData(deviceInfo)
        try keychainHelper.setDataInKeychain(data: deviceInfoData, forKey: getCurrentUserDeviceInfoStorageKey())
    }
    
    /// Set meta mapping in the keychain
    ///
    /// - Parameters:
    ///   - ethMetaMapping: EthMetaMapping object
    ///   - key: Storage key
    /// - Throws: OSTError
    func setMetaMapping(_ ethMetaMapping: EthMetaMapping, forKey key: String) throws {
        let address: String = ethMetaMapping.address.lowercased()
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        var ethKeyMappingData: [String: [String: Any]] = userDeviceInfo[key] as? [String: [String: Any]] ?? [:]
        ethKeyMappingData[address] = ethMetaMapping.toDictionary()
        userDeviceInfo[key] = ethKeyMappingData
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Get meta mapping for the given address and storage key
    ///
    /// - Parameters:
    ///   - address: Ethereum address for which the meta mapping is to be fetched
    ///   - key: Storage key
    /// - Returns: EthMetaMapping object if available otherwise nil
    func getMetaMapping(forAddress address: String, andKey key: String) -> EthMetaMapping? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        let ethKeyMappingData: [String: [String: Any]]? = userDeviceInfo[key] as? [String: [String: Any]]
        if let keyMappingValues =  ethKeyMappingData?[address.lowercased()] {
            return EthMetaMapping.getEthMetaMapping(from: keyMappingValues)
        }
        return nil
    }
    
    /// Get all address for a meta mapping type
    ///
    /// - Parameter key: Meta mapping key
    /// - Returns: Array of addresses
    func getAllAddresses(ForKey key:String) -> [String] {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        guard let ethKeyMappingData: [String: [String: Any]] = userDeviceInfo[key] as? [String: [String: Any]] else {
            return []
        }
        return Array(ethKeyMappingData.keys)
    }

    /// Delete meta mapping in the keychain
    ///
    /// - Parameters:
    ///   - ethMetaMapping: EthMetaMapping object
    ///   - key: Storage key
    /// - Throws: OSTError
    func deleteMetaMapping(forAddress address: String, forKey key: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        
        if var ethKeyMappingData:[String: Any] = userDeviceInfo[key] as? [String : Any] {
            if (ethKeyMappingData[address.lowercased()] != nil) {
                try deleteString(forKey: ethKeyMappingData["entityId"] as! String)
                ethKeyMappingData[address.lowercased()] = nil;
                userDeviceInfo[key] = ethKeyMappingData
                try setUserDeviceInfo(deviceInfo: userDeviceInfo)
            }
        }                
    }
    
    /// Store mnemonics in the keychain for given ethereum address
    ///
    /// - Parameters:
    ///   - mnemonics: Array containing 12 words
    ///   - address: Ethereum address
    /// - Throws: OSTError
    func storeMnemonics(_ mnemonics: [String], forAddress address: String) throws {
        let entityId = OstKeyManager.getMnemonicsStorageKey(forAddress: address)
        var ethMetaMapping = EthMetaMapping(address: address, entityId: entityId, identifier: self.secureEnclaveIdentifier)
        
        if let jsonString = try OstUtils.toJSONString(mnemonics) {
            try storeString(jsonString, ethMetaMapping: &ethMetaMapping)
            try setMnemonicsMetaMapping(ethMetaMapping)
            return
        }
        throw OstError.init("s_i_km_sm_1", .mnemonicsNotStored)
    }
    
    /// Store etheruem key in the keychain
    ///
    /// - Parameters:
    ///   - key: Storage key
    ///   - address: Ethereum address
    /// - Throws: OSTError
    func storeEthereumKey(_ key: String, forAddress address: String) throws {
        let entityId = OstKeyManager.getAddressStorageKey(forAddress: address)
        var ethMetaMapping = EthMetaMapping(address: address, entityId: entityId, identifier: self.secureEnclaveIdentifier)
        try storeString(key, ethMetaMapping: &ethMetaMapping)
        try setEthKeyMetaMapping(ethMetaMapping)
    }
    
    /// Store session key in the keychain
    ///
    /// - Parameters:
    ///   - key: Storage key
    ///   - address: Ethereum address
    /// - Throws: OSTError
    func storeSessionKey(_ key: String, forAddress address: String) throws {
        let entityId = OstKeyManager.getAddressStorageKey(forAddress: address)
        var ethMetaMapping = EthMetaMapping(address: address, entityId: entityId, identifier: self.secureEnclaveIdentifier)
        try storeString(key, ethMetaMapping: &ethMetaMapping)
        try setSessionKeyMetaMapping(ethMetaMapping)
    }
    
    /// Get session key from the keychain
    ///
    /// - Parameter address: Session address
    /// - Returns: Private key for given session address
    /// - Throws: OstError
    func getSessionKey(forAddress address: String) throws -> String? {
        if let ethMetaMapping: EthMetaMapping =  getSessionKeyMetaMapping(forAddress: address) {
            return try getString(from: ethMetaMapping)
        }
        return nil
    }

    /// Get the private key for the given ethereum address
    ///
    /// - Parameter address: Ethereum address
    /// - Returns: Private key for the ethereum address
    /// - Throws: OSTError
    func getEthereumKey(forAddresss address: String) throws -> String? {
        if let ethMetaMapping: EthMetaMapping =  getEthKeyMetaMapping(forAddress: address) {
            return try getString(from: ethMetaMapping)
        }
        return nil
    }
    
    /// Stores string in keychain. Updates the meta mapping object if the secure enclave encryption is performed
    ///
    /// - Parameters:
    ///   - string: A string that needs to be stored in keychain
    ///   - storageKey: Storage key
    ///   - ethMetaMapping: EthMetaMapping object
    /// - Throws: OSTError
    func storeString(_ string: String, ethMetaMapping: inout EthMetaMapping) throws {
        var eData: Data? = nil
        if #available(iOS 10.3, *) {
            if Device.hasSecureEnclave {
                let enclaveHelperObj = OstSecureEnclaveHelper(tag: ethMetaMapping.identifier)
                if let privateKey: SecKey = try enclaveHelperObj.getPrivateKey() {
                    eData = try enclaveHelperObj.encrypt(data: string.data(using: .utf8)!, withPrivateKey: privateKey)
                    ethMetaMapping.isSecureEnclaveEncrypted = true
                }
            }
        }
        if (eData == nil) {
            eData = OstUtils.toEncodedData(string)
            ethMetaMapping.identifier = ""
        }
        
        try keychainHelper.setDataInKeychain(data: eData!, forKey: ethMetaMapping.entityId)
    }
    
    /// Get the string for keychain. If the string was encrypted with secure enclave it will decrypt it
    ///
    /// - Parameters:
    ///   - ethMetaMapping: EthMetaMapping object
    /// - Returns: String
    /// - Throws: OSTError
    func getString(from ethMetaMapping: EthMetaMapping) throws -> String? {
        if let eData: Data = keychainHelper.getDataFromKeychain(forKey: ethMetaMapping.entityId) {
            if ethMetaMapping.isSecureEnclaveEncrypted {
                if #available(iOS 10.3, *) {
                    let enclaveHelperObj = OstSecureEnclaveHelper(tag: ethMetaMapping.identifier)
                    if let privateKey: SecKey = enclaveHelperObj.getPrivateKeyFromKeychain() {
                        let dData = try enclaveHelperObj.decrypt(data: eData, withPrivateKey: privateKey)
                        let jsonString: String = String(data: dData, encoding: .utf8)!
                        return jsonString
                    } else {
                        Logger.log(message: "Private key not found.")
                        throw OstError.init("s_i_km_gs_1", .noPrivateKeyFound)
                    }
                }
            }else {
                return OstUtils.toDecodedValue(eData) as? String
            }
        }
        return nil
    }
    
    /// Delete the string from keychain
    ///
    /// - Parameter key: Key to be deleted
    /// - Throws: OstError
    func deleteString(forKey key: String) throws {
        try keychainHelper.deleteStringFromKeychain(forKey: key)
    }
}

/// Signing related methods
extension OstKeyManager {
    /// Sign message with API private key
    ///
    /// - Parameter message: Message to sign
    /// - Returns: Signed message
    /// - Throws: OstError
    func signWithAPIKey(message: String) throws -> String {
        guard let apiPrivateKey = try self.getAPIKey() else{
            throw OstError.init("s_i_km_swpk_1", .noPrivateKeyFound)
        }
        return try sign(message, withPrivatekey: apiPrivateKey)
    }
    
    /// Sign message with device private key
    ///
    /// - Parameter tx: Transaction string to sign
    /// - Returns: Signed message
    /// - Throws: OstError
    func signWithDeviceKey(_ tx: String) throws -> String {
        guard let devicePrivateKey = try self.getDeviceKey() else{
            throw OstError.init("s_i_km_swdk_1", .noPrivateKeyFound)
        }
        return try signTx(tx, withPrivatekey: devicePrivateKey)
    }
    
    /// Sign message with session's private key
    ///
    /// - Parameter tx: Transaction string to sign
    /// - Returns: Signed message
    /// - Throws: OstError
    func signWithSessionKey(_ tx: String, withAddress address: String) throws -> String {
        guard let sessionPrivateKey = try self.getSessionKey(forAddress: address) else{
            throw OstError.init("s_i_km_swsk_1", .noPrivateKeyFound)
        }
        return try signTx(tx, withPrivatekey: sessionPrivateKey)
    }
    
    /// Sign message with private key that is generated by mnemonics keys
    ///
    /// - Parameters:
    ///   - tx: Transaction to sign
    ///   - mnemonics: 12 words mnemonics keys
    /// - Returns: Signed message
    /// - Throws: OstError
    func sign(_ tx: String, withMnemonics mnemonics: [String]) throws -> String {
        let ostWalletKeys = try OstCryptoImpls().generateEthereumKeys(withMnemonics: mnemonics)
        if (ostWalletKeys.address == nil || ostWalletKeys.privateKey == nil) {
            throw OstError("s_i_km_swm_1", .walletGenerationFailed)
        }
        return try signTx(tx, withPrivatekey: ostWalletKeys.privateKey!)
    }
    
    
    //TODO: - remove temp code and get code from Deepesh.
    func signWithRecoveryKey(
        tx:String,
        pin: String,
        password: String,
        salt: String) throws -> SignedData {
        
        let wallet = try OstCryptoImpls().getWallet(
            password: password,
            pin: pin,
            userId: self.userId,
            salt: salt,
            n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
            r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
            p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
            size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES
        )
        
        let privateKey = wallet.privateKey()
        let signedMessage = try signTx(tx, withPrivatekey: privateKey.toHexString())
        return (wallet.address(), signedMessage)
    }

    /// Sign message with private key
    ///
    /// - Parameter message: Message to sign
    /// - Returns: Signed message
    /// - Throws: OstError
    private func sign(_ message: String, withPrivatekey key: String) throws -> String {
        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: key,
                                     debugPrints: OstConstants.PRINT_DEBUG)
        
        var singedData: String
        do {
            singedData = try wallet.personalSign(message: message)
        } catch {
            throw OstError.init("s_i_km_s_1", .signTxFailed)
        }
        return singedData.addHexPrefix()
    }
    
    /// Sign the transaction with private key
    ///
    /// - Parameters:
    ///   - tx: Raw transaction string
    ///   - privateKey: private key string
    /// - Returns: Signed transaction string
    /// - Throws: OSTError
    private func signTx(_ tx: String, withPrivatekey privateKey: String) throws -> String {
        let priKey : PrivateKey = PrivateKey(raw: Data(hex: privateKey))
        
        var singedData: Data
        do {
            singedData = try priKey.sign(hash: Data(hex: tx))
        } catch {
            throw OstError.init("s_i_km_stx_1", .signTxFailed)
        }
        singedData[64] += 27
        let singedTx = singedData.toHexString().addHexPrefix();
        return singedTx
    }
}

enum Device {
    /// To check that device has secure enclave or not
    static var hasSecureEnclave: Bool {
        return !isSimulator && hasBiometrics
    }
    
    /// To Check that this is this simulator
    private static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR == 1
    }
    
    /// Check that this device has Biometrics features available
    private static var hasBiometrics: Bool {
        //Local Authentication Context
        let localAuthContext = LAContext()
        var error: NSError?
        
        /// Policies can have certain requirements which, when not satisfied, would always cause
        /// the policy evaluation to fail - e.g. a passcode set, a fingerprint
        /// enrolled with Touch ID or a face set up with Face ID. This method allows easy checking
        /// for such conditions.
        var isValidPolicy = localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        guard isValidPolicy == true else {
            
            if #available(iOS 11, *) {
                
                if error!.code != LAError.biometryNotAvailable.rawValue {
                    isValidPolicy = true
                } else{
                    isValidPolicy = false
                }
            }
            else {
                if error!.code != LAError.touchIDNotAvailable.rawValue {
                    isValidPolicy = true
                }else{
                    isValidPolicy = false
                }
            }
            return isValidPolicy
        }
        return isValidPolicy
    }
}
