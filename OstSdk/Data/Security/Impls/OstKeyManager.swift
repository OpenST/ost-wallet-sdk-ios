//
//  OstSdkSecureStoreImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct EthMetaMapping {
    var address: String
    var entityId: String
    var identifier: String
    var isSecureEnclaveEncrypted: Bool

    public init(address: String, identifier: String = "", isSecureEnclaveEncrypted: Bool = false) {
        self.address = address
        self.entityId = "Etherium_key_for_\(address)"
        self.identifier = identifier
        self.isSecureEnclaveEncrypted = isSecureEnclaveEncrypted
    }
    
    func toDictionary() -> [String: [String: Any]] {
        let dict: [String : Any] = ["entity_id": self.entityId,
                                    "identifier": self.identifier,
                                    "isSecureEnclaveEncrypted": self.isSecureEnclaveEncrypted]
        return [address: dict]
    }
}

public class OstKeyManager {
    
    var keychainHelper: OstKeychainHelper
    var userId: String
    
    var mUserDeviceInfo: [String: Any]? = nil
    
    public init (userId: String) {
        self.userId = userId
        keychainHelper = OstKeychainHelper(service: "com.ost")
    }
    
    //MARK: - API key
    func createAPIKey() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateCryptoKeys()
        
        try setEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try setAPIAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    func setAPIAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        
        userDeviceInfo["api_address"] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    public func getAPIAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo["api_address"] as? String
    }
    
    public func getAPIKey() throws -> String? {
        if let apiAddrss = getAPIAddress() {
            return try getEthereumKey(forAddresss: apiAddrss)
        }
        return nil
    }
    
    //MARK: - Device Key
    public func createKeyWithMnemonics() throws -> String {
        let ethKeys: OstWalletKeys = try OstCryptoImpls().generateCryptoKeys()
        
        try setMnemonics(ethKeys.mnemonics!, forAddress: ethKeys.address!)
        try setEthereumKey(ethKeys.privateKey!, forAddress: ethKeys.address!)
        try setDeviceAddress(ethKeys.address!)
        return ethKeys.address!
    }
    
    public func getDeviceAddress() -> String? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        return userDeviceInfo["device_address"] as? String
    }
    
    func setDeviceAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        userDeviceInfo["device_address"] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    public func getMnemonics(forAddresss address: String) throws -> [String]? {
        if let ethMetaMapping: EthMetaMapping =  getEthKeyMnenonicsMetaMapping(forAddress: address) {
            if let jsonString: String = try getAndDecrypt(forKey: "Etherium_key_Mnenonics_for_", ethMetaMapping: ethMetaMapping) {
                return try OstUtils.toJSONObject(jsonString) as? [String]
            }
        }
        return nil
    }
    
    public func getEthereumKey(forAddresss address: String) throws -> String? {
        if let ethMetaMapping: EthMetaMapping =  getEthKeyMetaMapping(forAddress: address) {
            return try getAndDecrypt(forKey: "Etherium_key_for_", ethMetaMapping: ethMetaMapping)
        }
        return nil
    }
    
    func hasAddresss(_ address: String) -> Bool {
        do {
            if let _ = try getEthereumKey(forAddresss: address) {
                return true
            }
        }catch { }
        return false
    }
}

extension OstKeyManager {
    //MARK: - EthKeyMappingData
    func setEthKeyMetaMapping(_ ethMetaMapping: EthMetaMapping) throws {
        try setMetaMapping(ethMetaMapping, forKey: "EthKeyMetaMapping")
    }
    
    func getEthKeyMetaMapping(forAddress address: String) -> EthMetaMapping?  {
        return getMetaMapping(key: "EthKeyMetaMapping", withAddress: address)
    }
    
    //MARK: - EthKeyMnenonicsMetaMapping
    func setEthKeyMnenonicsMetaMapping(_ ethMetaMapping: EthMetaMapping) throws {
        try setMetaMapping(ethMetaMapping, forKey: "EthKeyMnenonicsMetaMapping")
    }
    
    func getEthKeyMnenonicsMetaMapping(forAddress address: String) -> EthMetaMapping?  {
        return getMetaMapping(key: "EthKeyMnenonicsMetaMapping", withAddress: address)
    }
}

private extension OstKeyManager {
    
    func getUserDeviceInfo() -> [String: Any] {
        if (mUserDeviceInfo != nil) {
            return mUserDeviceInfo!
        }
        
        if let userDevice: Data = keychainHelper.get(forKey: "user_device_info_for_\(userId)") {
            mUserDeviceInfo = userDevice.toDictionary()
            return mUserDeviceInfo!
        }
        return [:]
    }
    
    func setUserDeviceInfo(deviceInfo: [String: Any]) throws {
        mUserDeviceInfo = deviceInfo
        let deviceInfoData = OstUtils.toEncodedData(deviceInfo)
        try keychainHelper.hardSet(data: deviceInfoData, forKey: "user_device_info_for_\(userId)")
    }
    
    func setMetaMapping(_ ethMetaMapping: EthMetaMapping, forKey key: String) throws {
        let address: String = ethMetaMapping.address
        var ethKeyMappingData: [String: [String: Any]]?
        var userDeviceInfo: [String: Any] = getUserDeviceInfo()
        
        
        ethKeyMappingData = userDeviceInfo[key] as? [String: [String: Any]]
        if (ethKeyMappingData != nil) {
            ethKeyMappingData![address] = ethMetaMapping.toDictionary()[address]
            try setUserDeviceInfo(deviceInfo: ethKeyMappingData!)
        }
        
        ethKeyMappingData = ([address: ethMetaMapping.toDictionary()[address]] as! [String : [String : Any]])
        userDeviceInfo[key] = ethKeyMappingData
        try setUserDeviceInfo(deviceInfo: userDeviceInfo)
    }
    
    func getMetaMapping(key: String, withAddress address: String) -> EthMetaMapping? {
        let userDeviceInfo: [String: Any] = getUserDeviceInfo()
        let ethKeyMappingData: [String: [String: Any]]? = userDeviceInfo[key] as? [String: [String: Any]]
        if let keyMappingValues =  ethKeyMappingData?[address] {
            return EthMetaMapping(address: address,
                                     identifier: keyMappingValues["identifier"] as! String,
                                     isSecureEnclaveEncrypted: keyMappingValues["isSecureEnclaveEncrypted"] as! Bool)
        }
        return nil
    }
    
    func setMnemonics(_ mnemonics: [String], forAddress address: String) throws {
        let enclaveIdentifier = "\(address).Mnemonics"
        var ethMetaMapping = EthMetaMapping(address: address, identifier: enclaveIdentifier)
        
        if let jsonString = try OstUtils.toJSONString(mnemonics) {
            try encryptAndStoreString(jsonString, forKey: "Etherium_key_Mnenonics_for_", ethMetaMapping: &ethMetaMapping)
            try setEthKeyMnenonicsMetaMapping(ethMetaMapping)
            return
        }
        throw OstError.actionFailed("Mnemonics can not stored")
    }
    
    func setEthereumKey(_ key: String, forAddress address: String) throws {
        let enclaveIdentifier = "\(address).Key"
        var ethMetaMapping = EthMetaMapping(address: address, identifier: enclaveIdentifier)
        try encryptAndStoreString(key, forKey: "Etherium_key_for_", ethMetaMapping: &ethMetaMapping)
        try setEthKeyMetaMapping(ethMetaMapping)
    }
    
    func encryptAndStoreString(_ string: String, forKey key: String, ethMetaMapping: inout EthMetaMapping) throws {
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
        
        try keychainHelper.hardSet(data: eData!, forKey: "\(key)\(ethMetaMapping.address)")
    }
    
    func getAndDecrypt(forKey key: String, ethMetaMapping: EthMetaMapping) throws -> String? {
        if let eData: Data = keychainHelper.get(forKey: "\(key)\(ethMetaMapping.address)") {
            if ethMetaMapping.isSecureEnclaveEncrypted {
                if #available(iOS 10.3, *) {
                    let enclaveHelperObj = OstSecureEnclaveHelper(tag: ethMetaMapping.identifier)
                    if let privateKey: SecKey = try enclaveHelperObj.getPrivateKey() {
                        let dData = try enclaveHelperObj.decrypt(data: eData, withPrivateKey: privateKey)
                        let jsonString: String = String(data: dData, encoding: .utf8)!
                        return jsonString
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
    
    //To check that device has secure enclave or not
    public static var hasSecureEnclave: Bool {
        return !isSimulator && hasBiometrics
    }
    
    //To Check that this is this simulator
    public static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR == 1
    }
    
    //Check that this device has Biometrics features available
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

