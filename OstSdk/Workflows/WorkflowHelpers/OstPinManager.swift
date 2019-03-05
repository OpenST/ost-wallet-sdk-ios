//
//  OstPinManager.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 04/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstPinManager {
    private let ostPinManagerQueue = DispatchQueue(label: "OstPinManager", qos: .background)
    private let userId: String
    private let password: String
    private let pin: String
    private var newPin: String? = nil
    private var salt: String? = nil
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - password: App password
    ///   - pin: User pin
    ///   - newPin: User new pin
    init(userId: String,
         password: String,
         pin: String,
         newPin: String? = "") {
        
        self.userId = userId
        self.password = password
        self.pin = pin
        self.newPin = newPin
    }
    
    /// Validate pin length
    ///
    /// - Throws: OstError
    func validatePinLength() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.pin.count {
            throw OstError.init(
                "w_wh_pm_vpl_1",
                "New pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)"
            )
        }
    }
    /// Validate Password length
    ///
    /// - Throws: OstError
    func validatePasswordLength() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.password.count {
            throw OstError.init(
                "w_wh_pm_vpwdl_1",
                "Password must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)"
            )
        }
    }
    
    /// Validate pin data
    ///
    /// - Returns: `true` if valid otherwise `false`
    /// - Throws: OstError
    func validatePin() throws -> Bool{
        try self.validate()
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wv_vp_1", .userEntityNotFound)
        }
        do {
            let isValid = try OstKeyManager(userId: self.userId)
                .verifyPin(
                    password: self.password,
                    pin: self.pin,
                    salt: self.salt!,
                    recoveryOwnerAddress: user.recoveryOwnerAddress!
            )
            if isValid {
                return isValid
            }
            throw OstError("w_wh_ph_vp_1", .pinValidationFailed)
        } catch {
            // Fallback
            let recoveryOwnerAddress = try OstKeyManager(userId: self.userId)
                .getRecoveryOwnerAddressFrom(
                    password: self.password,
                    pin: self.pin,
                    salt: self.salt!
            )
            return recoveryOwnerAddress.caseInsensitiveCompare((user.recoveryOwnerAddress)!) ==  .orderedSame
        }
    }
    
    /// Validate reset pin params
    ///
    /// - Returns: `true` if valid otherwise `false`
    /// - Throws: OstError
    func validateResetPin() throws -> Bool {
        try self.validateNewPinLength()
        return try self.validatePin()
    }
    
    /// Get recovery owner address
    ///
    /// - Returns: Recovery owner address
    func getRecoveryOwnerAddress() -> String? {
        do {
            try self.validatePinLength()
            try self.validatePasswordLength()
            try self.validateSaltLength()
            try self.fetchSalt()
            return try OstKeyManager(userId: self.userId)
                .getRecoveryOwnerAddressFrom(
                    password: self.password,
                    pin: self.pin,
                    salt: self.salt!
            )
        }catch {
            return nil
        }
    }
    
    /// Get recovery owner address for new pin
    ///
    /// - Returns: Recovery owner address
    func getRecoveryOwnerAddressForNewPin() -> String? {
        do {
            try self.validateNewPinLength()
            try self.validatePasswordLength()
            try self.validateSaltLength()
            try self.fetchSalt()
            return try OstKeyManager(userId: self.userId)
                .getRecoveryOwnerAddressFrom(
                    password: self.password,
                    pin: self.newPin!,
                    salt: self.salt!
            )
        }catch {
            return nil
        }        
    }
    
    /// Get signed data for pin reset
    ///
    /// - Parameter newRecoveryOwnerAddress: New recovery owner address
    /// - Returns: SignedData
    /// - Throws: OstError
    func signResetPinData(newRecoveryOwnerAddress: String) throws -> OstKeyManager.SignedData {
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wh_pm_srpd_1", .userEntityNotFound)
        }
        if (!user.isStatusActivated) {
            throw OstError("w_wh_pm_srpd_2", .userNotActivated)
        }
        guard let recoveryAddress = user.recoveryAddress else {
            throw OstError("w_wh_pm_srpd_3", .recoveryAddressNotFound)
        }
        guard let recoveryOwnerAddress = user.recoveryOwnerAddress else {
            throw OstError("w_wh_pm_srpd_4", .recoveryOwnerAddressNotFound)
        }
        let typedDataInput: [String: Any] = TypedDataForResetPin
            .getResetPinTypedData(
                verifyingContract: recoveryAddress,
                oldRecoveryOwner: recoveryOwnerAddress,
                newRecoveryOwner: newRecoveryOwnerAddress
        )
        
        let eip712: EIP712 = EIP712(
            types: typedDataInput["types"] as! [String: Any],
            primaryType: typedDataInput["primaryType"] as! String,
            domain: typedDataInput["domain"] as! [String: String],
            message: typedDataInput["message"] as! [String: Any]
        )
        
        let signingHash = try! eip712.getEIP712SignHash()
        
        let signedData = try OstKeyManager(userId: self.userId)
            .signWithRecoveryKey(
                tx: signingHash,
                pin: self.pin,
                password: self.password,
                salt: self.salt!
            )
        
        if (user.recoveryOwnerAddress!.caseInsensitiveCompare(signedData.address) != .orderedSame) {
            throw OstError("w_wh_pm_srpd_5", .invalidRecoveryAddress)
        }
        
        return signedData
    }
    
    /// Get signed data for recover device
    ///
    /// - Parameter deviceAddressToRecover: Device address that needs to be recovered
    /// - Returns: SignedData
    /// - Throws: OstError
    func signRecoverDeviceData(deviceAddressToRecover: String) throws -> OstKeyManager.SignedData {
        let isPinValid = try validatePin()
        if (isPinValid) {
            guard let user = try OstUser.getById(self.userId) else {
                throw OstError("w_wh_pm_srdd_1", .userEntityNotFound)
            }
            if (!user.isStatusActivated) {
                throw OstError("w_wh_pm_srdd_2", .userNotActivated)
            }
            guard let recoveryOwnerAddress = user.recoveryOwnerAddress else {
                throw OstError("w_wh_pm_srdd_3", .recoveryAddressNotFound)
            }
            guard let device = try OstDevice.getById(deviceAddressToRecover) else {
                throw OstError("w_wh_pm_srdd_4", .deviceNotFound)
            }
            guard let linkedAddress = device.linkedAddress else {
                throw OstError("w_wh_pm_srdd_5", .linkedAddressNotFound)
            }
            if (!device.isStatusAuthorized) {
                throw OstError("w_wh_pm_srdd_6", .deviceNotAuthorized)
            }
            guard let currentDevice = user.getCurrentDevice() else {
                throw OstError("w_wh_pm_srdd_6", .deviceNotFound)
            }
            if (!currentDevice.isStatusRegistered) {
                throw OstError("w_wh_pm_srdd_7", .deviceNotRegistered)
            }
            let typedData = TypedDataForRecovery
                .getInitiateRecoveryTypedData(
                    verifyingContract: recoveryOwnerAddress,
                    prevOwner: linkedAddress,
                    oldOwner: deviceAddressToRecover,
                    newOwner: currentDevice.address!
            )
            
            let eip712: EIP712 =  EIP712(types: typedData["types"] as! [String: Any],
                                         primaryType: typedData["primaryType"] as! String,
                                         domain: typedData["domain"] as! [String: String],
                                         message: typedData["message"] as! [String: Any])
            
            let signingHash = try eip712.getEIP712SignHash()
            
            let signedData = try OstKeyManager(userId: self.userId)
                .signWithRecoveryKey(
                    tx: signingHash,
                    pin: self.pin,
                    password: self.password,
                    salt: self.salt!
                )

            if (user.recoveryOwnerAddress!.caseInsensitiveCompare(signedData.address) != .orderedSame) {
                throw OstError("w_wh_pm_srdd_8", .invalidRecoveryAddress)
            }
            return signedData
        } else {
            throw OstError("w_wh_pm_srdd_9", .pinValidationFailed)
        }
    }
    
    /// Validate salt length
    ///
    /// - Throws: OstError
    private func validateSaltLength() throws {
        try self.fetchSalt()
        
        if self.salt!.count == 0 {
            throw OstError.init(
                "w_wh_pm_vsl_1",
                "Invalid salt"
            )
        }
    }
    
    /// Validate new pin length
    ///
    /// - Throws: OstError
    private func validateNewPinLength() throws {
        if (self.newPin == nil || OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.newPin!.count) {
            throw OstError.init(
                "w_wh_pm_v_1",
                "New pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)"
            )
        }
    }
    /// Validate pin data
    ///
    /// - Throws: OstError
    private func validate() throws{
        try self.validatePinLength()
        try self.validatePasswordLength()
        try self.validateSaltLength()
    }
    
    /// Fetch salt from server
    ///
    /// - Throws: OstError
    private func fetchSalt() throws{
        if (self.salt == nil) {
            let group = DispatchGroup()
            
            var salt: [String: Any]?
            var err: OstError? = nil
            group.enter()
            ostPinManagerQueue.async {
                do {
                    try OstAPISalt(userId: self.userId)
                        .getRecoverykeySalt(
                            onSuccess: { (saltResponse) in
                                salt = saltResponse
                                group.leave()
                        },
                            onFailure: { (error) in
                                err = error
                                group.leave()
                        }
                    )
                } catch {
                    err = OstError("w_wh_ph_fs_1", .unableToGetSalt)
                    group.leave()
                }
            }
            group.wait()
            if (err != nil) {
                throw err!
            }
            self.salt = salt!["scrypt_salt"] as? String
        }
    }
}
