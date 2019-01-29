//
//  OstSdkSecureStoreImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import LocalAuthentication

public class OstSecureStoreImpls {
    
    private var address = ""

    public init(address: String) throws {
        self.address = address

    }
    
    func encrypt(data: Data) throws -> Data? {
        if #available(iOS 10.3, *) {
            if (Device.hasSecureEnclave && !Device.isSimulator) {
                return try OstSecureEnclaveHelper(address: address).encrypt(data: data)
            }
        }

        return try OstKeychainHelper(address: address).encrypt(data)
    }

    func decrypt(data: Data) throws -> Data? {
        if #available(iOS 10.3, *) {
            if (Device.hasSecureEnclave && !Device.isSimulator) {
                return try OstSecureEnclaveHelper(address: address).decrypt(data: data)
            }
        }
        return try OstKeychainHelper(address: address).decrypt(data)
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

