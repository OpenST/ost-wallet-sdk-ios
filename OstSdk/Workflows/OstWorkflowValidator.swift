//
//  OstWorkflowValidator.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkflowValidator {
    
    let currentUser: OstUser
    
    /// Initializer
    init(withUserId userId: String) throws {
        guard let ostUser: OstUser = try OstUser.getById(userId) else {
            throw OstError("w_wv_i_1", .userEntityNotFound)
        }
        self.currentUser = ostUser
    }
    
    // MARK: - Device related validations
    
    /// Is device status authorizes
    ///
    /// - Returns: `true` if authorized otherwise `false`
    /// - Throws: OstError
    func isDeviceAuthrorized() throws -> Bool {
        guard let currentDevice = self.currentUser.getCurrentDevice() else {
            throw OstError("w_wv_ida_1", .deviceNotFound);
        }
        return currentDevice.isStatusAuthorized
    }
    
    // MARK: - User related validations
    
    /// Is user activated
    ///
    /// - Returns: `true` if user status is activated otherwise `false`
    /// - Throws: OstError
    func isUserActivated() throws -> Bool {
        return self.currentUser.isStatusActivated
    }
    
    
    /// Validate params related to pin
    ///
    /// - Parameters:
    ///   - pin: Pin
    ///   - appPassword: Password
    ///   - salt: Salt
    /// - Throws: OstError
    func validatePinParams(pin: String, appPassword: String, salt: String) throws{
        try validateAppPasswordLength(appPassword)
        try validatePinLength(pin)
        try validateSaltLength(salt)
    }
    
    /// Validate the pin
    ///
    /// - Parameters:
    ///   - pin: Pin
    ///   - appPassword: Password
    ///   - salt: Salt
    /// - Returns: `true` if valid otherwise `false`
    /// - Throws: OstError
    func validatePin(pin: String, appPassword: String, salt: String) throws -> Bool {
        try validatePinParams(pin: pin, appPassword: appPassword, salt: salt)
        guard let user = try OstUser.getById(self.currentUser.id) else {
            throw OstError("w_wv_vp_1", .userEntityNotFound)
        }
        let isValid = try OstKeyManager(userId: self.currentUser.id)
            .verifyPin(
                password: appPassword,
                pin: pin,
                salt: salt,
                recoveryOwnerAddress: user.recoveryOwnerAddress!
        )
        return isValid
    }
    
    
    /// Validate app password length
    ///
    /// - Parameter appPassword: App password
    /// - Throws: OstError
    func validateAppPasswordLength(_ appPassword: String) throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > appPassword.count {
            throw OstError.init(
                "w_wfv_vapl_1",
                "Password must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)"
            )
        }
    }
    /// Validate pin length
    ///
    /// - Parameter pin: Pin string
    /// - Throws: Ost error
    func validatePinLength(_ pin: String) throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > pin.count {
            throw OstError.init(
                "w_wfv_vpl_1",
                "Pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)"
            )
        }
    }
    
    // TODO: please check and verify the condition
    /// Validate salt lenth
    ///
    /// - Parameter salt: Salt string
    /// - Throws: OstError
    func validateSaltLength(_ salt: String) throws {
        if salt.count == 0 {
            throw OstError.init(
                "w_wfv_vsl_1",
                "Invalid salt"
            )
        }
    }
    
    func isAPIKeyAvailable() -> Bool {
        guard let apiAddress = OstKeyManager(userId: self.currentUser.id).getAPIAddress() else {
            return false
        }
        return apiAddress.count > 0
    }
    
    func isTokenAvailable() -> Bool {
        guard let tokenId = self.currentUser.tokenId else {
            return false
        }
        do {
            let _ = try OstToken.getById(tokenId)
        } catch {
            return false
        }
        return true
    }
}


