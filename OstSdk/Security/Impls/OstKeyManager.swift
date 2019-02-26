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

let SERVICE_NAME = "com.ost"
let ETHEREUM_KEY_PREFIX = "Ethereum_key_for_"
let MNEMONICS_KEY_PREFIX = "Mnemonics_for_"
let SECURE_ENCLAVE_KEY_PREFIX = "secure_enclave_identifier_"
let USER_DEVICE_KEY_PREFIX = "user_device_info_for_"
let ETH_META_MAPPING_KEY = "EthKeyMetaMapping"
let MNEMONICS_META_MAPPING_KEY = "EthKeyMnemonicsMetaMapping"
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
    public init(address: String, entityId: String, identifier: String = "", isSecureEnclaveEncrypted: Bool = false) {
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
    
    // MARK: - Instance varaibles
    
    /// Helper object to interact with keychain
    var keychainHelper: OstKeychainHelper
    
    /// Current user id
    var userId: String
    
    /// Secure enclave identifier key
    var secureEnclaveIdentifier: String
    
    /// Current user's device info
    var currentUserDeviceInfo: [String: Any]? = nil
    
    // MARK: - Initializers
    
    /// Class initializer
    ///
    /// - Parameter userId: User id whose keys will be managed.
    public init (userId: String) {
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
        try storeEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try storeAPIAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    /// Store the API address in keychain
    ///
    /// - Parameter address: Ethereum address that needs to be stored
    /// - Throws: Exceptions that occurs while storing the address
    func storeAPIAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo[API_ADDRESS_KEY] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Get the current users API address
    ///
    /// - Returns: API address
    public func getAPIAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo[API_ADDRESS_KEY] as? String
    }
    
    /// Get the private key for the API address
    ///
    /// - Returns: Private key for the API address if available otherwise nil
    /// - Throws: Exception that occurs while getting the private key
    public func getAPIKey() throws -> String? {
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
    public func createDeviceKey() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateOstWalletKeys()
        try storeMnemonics(ethKeys.mnemonics!, forAddress: ethKeys.address!)
        try storeEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try storeDeviceAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    /// Store the device address in the keychain
    ///
    /// - Parameter address: Device address
    /// - Throws: Exception that occurs while storing the device address in keychain
    func storeDeviceAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo[DEVICE_ADDRESS_KEY] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Get current user's stored device address from keychain
    ///
    /// - Returns: Device address if available otherwise nil
    public func getDeviceAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo[DEVICE_ADDRESS_KEY] as? String
    }
    
    /// Get private key of current user's stored device address
    ///
    /// - Returns: Private key for device address if available otherwise nil
    /// - Throws: Exception that accurs while getting the private key from keychain
    public func getDeviceKey() throws -> String? {
        if let deviceAddress = getDeviceAddress() {
            return try getEthereumKey(forAddresss: deviceAddress)
        }
        return nil
    }
    
    /// Get the 12 words mnemonic keys for the current user's device address
    ///
    /// - Returns: JSON serialized 12 words mnemonics key
    /// - Throws: Exception that occurs while getting the keys from keychain
    public func getDeviceMnemonics() throws -> [String]? {
        if let deviceAddress = getDeviceAddress() {
            if let ethMetaMapping: EthMetaMapping =  getMnemonicsMetaMapping(forAddress: deviceAddress) {
                if let jsonString: String = try getString(from: ethMetaMapping) {
                    return try OstUtils.toJSONObject(jsonString) as? [String]
                }
            }
        }
        return nil
    }
    
    //TODO: - Store data from keychain.
    /// Store recovery pin string in key chain
    ///
    /// - Parameter pinString: Pin string generated at the time of activate user.
    /// - Returns:  true if data stored in keychain successfully.
    public func storeRecoveryPinString(_ pinString: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        let stringHash = pinString.sha3(.keccak256)
        let hashData = stringHash.data(using: .utf8)!

        userDeviceInfo[RECOVERY_PIN_HASH] = OstUtils.toEncodedData(hashData)
        
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    /// Verify stored pin string with passed one.
    ///
    /// - Parameter pinString: Pin string generated at the time of activate user.
    /// - Returns: true if data stored in keychain successfully.
    public func verifyRecoveryPinString(_ pinString: String) -> Bool {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        let hashEncodedData : Data = userDeviceInfo[RECOVERY_PIN_HASH] as! Data
        let hashData = OstUtils.toDecodedValue(hashEncodedData) as! Data
        let storedStringHash = String(bytes: hashData, encoding: .utf8)!
        
        let pinHash = pinString.sha3(.keccak256)
        
        return (pinHash == storedStringHash)
    }
}

// MARK: - MetaMapping getters and setters
extension OstKeyManager {
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
        throw OstError1.init("s_i_km_sm_1", .mnemonicsNotStored)
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
                        throw OstError1.init("s_i_km_gs_1", .noPrivateKeyFound)
                    }
                }
            }else {
                return OstUtils.toDecodedValue(eData) as? String
            }
        }
        return nil
    }
}

enum Device {
    /// To check that device has secure enclave or not
    public static var hasSecureEnclave: Bool {
        return !isSimulator && hasBiometrics
    }
    
    /// To Check that this is this simulator
    public static var isSimulator: Bool {
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
