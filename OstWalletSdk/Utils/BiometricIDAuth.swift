/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import LocalAuthentication

class BiometricIDAuth {
    
    private let context = LAContext()
    private var permissionText = "Please authenticate yourself to access sensitive information."
    
    init(permissionText: String? = nil) {
        if (nil != permissionText && !permissionText!.isEmpty) {
            self.permissionText = permissionText!
        }
    }
    
    /// Authenticate user with biometrics
    ///
    /// - Parameter completion: Complection callback
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion(false, "Touch ID not available")
            return
        }
        context.touchIDAuthenticationAllowableReuseDuration = 10
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: permissionText) { (success, evaluatePolicyError) in
            if success {
                completion(true, nil)
            } else {
                var message: String = ""
                
                switch evaluatePolicyError {
                case LAError.authenticationFailed?:
                    message = "Authentication was not successful, because user failed to provide valid credentials."
                case LAError.userCancel?:
                    message = "Authentication was canceled by user."
                case LAError.userFallback?:
                    message = "Authentication was canceled, because the user tapped the fallback button."
                default:
                    message = "Face ID/Touch ID may not be configured."
                }
                if #available(iOS 11.0, *) {
                    switch evaluatePolicyError {
                    case LAError.biometryNotAvailable?:
                        message = "Authentication could not start, because biometry is not available on the device."
                    case LAError.biometryNotEnrolled?:
                        message = "Authentication could not start, because biometry has no enrolled identities."
                    case LAError.biometryLockout?:
                        message = "Authentication was not successful, because there were too many failed biometry attempts."
                    default:
                        message = "Face ID/Touch ID may not be configured."
                    }
                } else {
                    switch evaluatePolicyError {
                    case LAError.touchIDLockout?:
                        message = "Authentication was not successful, because there were too many failed Touch ID attempts."
                    case LAError.touchIDNotEnrolled?:
                        message = "Authentication could not start, because Touch ID has no enrolled fingers."
                    case LAError.touchIDNotAvailable?:
                        message = "Authentication could not start, because Touch ID is not available on the device."
                    default:
                        message = "Touch ID may not be configured."
                    }
                }
                completion(false ,message)
            }
        }
    }
    
    /// Check for owner authentication with biometrics
    ///
    /// - Returns: Boolean
    private func canEvaluatePolicy() -> Bool {
        let canDeviceEvaluatePolicy: Bool = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if canDeviceEvaluatePolicy {
            if #available(iOS 11.0, *) {
                switch self.context.biometryType {
                case .none:
                    return false
                    
                case .faceID:
                    let content = OstBundle.getApplicationPlistContent(for: OstBundle.PermissionKey.NSFaceIDUsageDescription.rawValue,
                                                        fromFile: "Info")
                    if ( nil == content ) {
                        return false
                    }
                    break;
                case .touchID:
                    return true
                }
            }
        }
        return canDeviceEvaluatePolicy
    }
}
