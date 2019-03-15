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
                    message = "Authentication was not successful, because user failed to provide valid credentials."
                case LAError.userCancel?:
                    message = "Authentication was canceled by user"
                case LAError.userFallback?:
                    message = "Authentication was canceled, because the user tapped the fallback button."
                default:
                    message = "Face ID/Touch ID may not be configured"
                }
                if #available(iOS 11.0, *) {
                    switch evaluateError {
                    case LAError.biometryNotAvailable?:
                        message = "Authentication could not start, because biometry is not available on the device."
                    case LAError.biometryNotEnrolled?:
                        message = "Authentication could not start, because biometry has no enrolled identities."
                    case LAError.biometryLockout?:
                        message = "Authentication was not successful, because there were too many failed biometry attempts."
                    default:
                        message = "Face ID/Touch ID may not be configured"
                    }
                } else {
                    switch evaluateError {
                    case LAError.touchIDLockout?:
                        message = "Authentication was not successful, because there were too many failed Touch ID attempts."
                    case LAError.touchIDNotEnrolled?:
                        message = "Authentication could not start, because Touch ID has no enrolled fingers."
                    case LAError.touchIDNotAvailable?:
                        message = "Authentication could not start, because Touch ID is not available on the device."
                    default:
                        message = "Touch ID may not be configured"
                    }
                }
                completion(false ,message)
            }
        }
    }
}
