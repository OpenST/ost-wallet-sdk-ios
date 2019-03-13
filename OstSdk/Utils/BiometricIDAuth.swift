/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricIDAuth {
    private let context = LAContext()
    private var loginReason = "Please authenticate yourself to access sensitive information."
    
    private func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        }
        return .none
    }
    
    private func canEvaluatePolicy() -> Bool {
        var canDeviceEvaluatePolicy: Bool = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if canDeviceEvaluatePolicy {
            if #available(iOS 11.0, *) {
                switch self.context.biometryType {
                case .none:
                    canDeviceEvaluatePolicy = false
                    
                case .faceID:
                    do {
                        _ = try OstBundle
                            .getApplicationPlistContent(for: OstBundle.PermissionKey.NSFaceIDUsageDescription.rawValue,
                                                        fromFile: "Info")
                    }catch {
                        canDeviceEvaluatePolicy = false
                    }
                    
                case .touchID:
                    canDeviceEvaluatePolicy = true
                }
            }
        }
        return canDeviceEvaluatePolicy
    }
    
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion(false, "Touch ID not available")
            return
        }
        context.touchIDAuthenticationAllowableReuseDuration = 10
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                completion(true, nil)
            } else {
                var message: String = ""
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                if #available(iOS 11.0, *) {
                    switch evaluateError {
                    case LAError.biometryNotAvailable?:
                        message = "Face ID/Touch ID is not available."
                    case LAError.biometryNotEnrolled?:
                        message = "Face ID/Touch ID is not set up."
                    case LAError.biometryLockout?:
                        message = "Face ID/Touch ID is locked."
                    default:
                        message = "Face ID/Touch ID may not be configured"
                    }
                } else {
                    switch evaluateError {
                    case LAError.touchIDLockout?:
                        message = "Touch ID is locked."
                    case LAError.touchIDNotEnrolled?:
                        message = "Touch ID is not set up."
                    case LAError.touchIDNotAvailable?:
                        message = "Touch ID is not available."
                    default:
                        message = "Touch ID may not be configured"
                    }
                }
                completion(false ,message)
            }
        }
    }
}
