//
//  OstSdkSecureStoreImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import LocalAuthentication

public struct OstEthMetaMapping {
    var address: String
    var entityId: String
    var identifier: String
    
    public init(address: String, identifier: String) {
        self.address = address
        self.entityId = "Etherium_key_for_\(address)"
        self.identifier = identifier
    }
    
    func toDictionary() -> [String: [String: String]] {
        let dict = ["entity_id": self.entityId,
                    "identifier": self.identifier]
        return [address: dict]
    }
}

public class OstSecureStoreImpls {
    
    var keychainHelper: OstKeychainHelper
    var userId: String
    
    public init (userId: String) {
        self.userId = userId
        keychainHelper = OstKeychainHelper(service: "com.ost")
    }
    
    //MARK: - EthKeyMappingData
    public func setEthKeyMappingData(_ ethMetaMapping: OstEthMetaMapping) throws {
        try setEthMetaMapping(ethMetaMapping, forKey: "EthKeyMappingData")
    }
    
    public func getEthKeyMappingData(forAddress address: String) -> [String: String]?  {
        if let userDeviceInfo: [String: Any] = getUserDeviceInfo() {
            let ethKeyMappingData: [String: [String: String]]? = userDeviceInfo["EthKeyMappingData"] as? [String: [String: String]]
            return ethKeyMappingData?[address]
        }
        return nil
    }
    
    //MARK: - EthKeyMnenonicsMetaMapping
    public func setEthKeyMnenonicsMetaMapping(_ ethMetaMapping: OstEthMetaMapping) throws {
        try setEthMetaMapping(ethMetaMapping, forKey: "EthKeyMnenonicsMetaMapping")
    }
    
    public func getEthKeyMnenonicsMetaMapping(forAddress address: String) -> [String: String]?  {
        if let userDeviceInfo: [String: Any] = getUserDeviceInfo() {
            let ethKeyMappingData: [String: [String: String]]? = userDeviceInfo["EthKeyMnenonicsMetaMapping"] as? [String: [String: String]]
            return ethKeyMappingData?[address]
        }
        return nil
    }
    
    //MARK: - API address
    public func setAPIAddress(_ address: String) throws {
        var userDeviceInfo: [String: Any]? = getUserDeviceInfo()
        
        if (userDeviceInfo == nil) {
            userDeviceInfo = [:]
        }
        userDeviceInfo!["api_address"] = address
        try setUserDeviceInfo(deviceInfo: userDeviceInfo!)
    }
    
    public func getAPIAddress() -> String? {
        if let userDeviceInfo: [String: Any] = getUserDeviceInfo() {
            return userDeviceInfo["api_address"] as? String
        }
        return nil
    }
    
    //MARK: - fileprivate
    fileprivate func setEthMetaMapping(_ ethMetaMapping: OstEthMetaMapping, forKey key: String) throws {
        let address: String = ethMetaMapping.address
        var ethKeyMappingData: [String: [String: String]]?
        var userDeviceInfo: [String: Any]? = getUserDeviceInfo()
        
        if (userDeviceInfo == nil) {
            userDeviceInfo = [:]
        }else {
            ethKeyMappingData = userDeviceInfo![key] as? [String: [String: String]]
            if (ethKeyMappingData != nil) {
                ethKeyMappingData![address] = ethMetaMapping.toDictionary()[address]
                try setUserDeviceInfo(deviceInfo: ethKeyMappingData!)
            }
        }
        
        ethKeyMappingData = ([address: ethMetaMapping.toDictionary()[address]] as! [String : [String : String]])
        userDeviceInfo![key] = ethKeyMappingData
        try setUserDeviceInfo(deviceInfo: userDeviceInfo!)
    }
    
    fileprivate func getUserDeviceInfo() -> [String: Any]? {
        if let userDeviceInfo: Data = keychainHelper.get(forKey: "user_device_info_for_\(userId)") {
            return userDeviceInfo.toDictionary()
        }
        return nil
    }
    
    fileprivate func setUserDeviceInfo(deviceInfo: [String: Any]) throws {
        let deviceInfoData = deviceInfo.toEncodedData()
        try keychainHelper.hardSet(data: deviceInfoData, forKey: "user_device_info_for_\(userId)")
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

