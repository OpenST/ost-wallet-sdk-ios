/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstPinManager {
    private let ostPinManagerQueue = DispatchQueue(label: "OstPinManager", qos: .background)
    private let userId: String
    private let passphrasePrefix: String
    private let userPin: String
    private let keyManagareDelegate: OstKeyManagerDelegate
    
    private var newUserPin: String? = nil
    private var salt: String? = nil
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - passphrasePrefix: App passphrase prefix
    ///   - userPin: User pin
    ///   - newUserPin: User new pin
    init(userId: String,
         passphrasePrefix: String,
         userPin: String,
         newUserPin: String? = "",
         keyManagareDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.passphrasePrefix = passphrasePrefix
        self.userPin = userPin
        self.newUserPin = newUserPin
        self.keyManagareDelegate = keyManagareDelegate
    }
    
    /// Validate user pin length
    ///
    /// - Throws: OstError
    func validatePinLength() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.userPin.count {
            throw OstError(internalCode: "w_wh_pm_vpl_1", errorCode: .invalidUserPassphrase );
        }
    }
    /// Validate passphrase prefix length
    ///
    /// - Throws: OstError
    func validatePassphrasePrefixLength() throws {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.passphrasePrefix.count {
            throw OstError(internalCode: "w_wh_pm_vpl_1", errorCode: .invalidPassphrasePrefix );            
        }
    }
    
    /// Validate pin data
    ///
    /// - Returns: `true` if valid otherwise `false`
    /// - Throws: OstError
    func validatePin() throws{
        try self.validate()
        let user = try self.fetchUser()
        if nil == user.recoveryOwnerAddress {
            throw OstError("s_ecki_pm_vp_1", .recoveryOwnerAddressNotFound)
        }
        let isValid = self.keyManagareDelegate
            .verifyPin(passphrasePrefix: self.passphrasePrefix,
                       userPin: self.userPin,
                       salt: self.salt!,
                       recoveryOwnerAddress: user.recoveryOwnerAddress!
        )
        if !isValid {
            throw OstError("w_wh_ph_vp_1", .invalidUserPassphrase)
        }
    }
    
    /// Validate reset pin params
    ///
    /// - Returns: `true` if valid otherwise `false`
    /// - Throws: OstError
    func validateResetPin() throws{
        try self.validateNewPinLength()
        try self.validatePin()
    }
    
    /// Get recovery owner address
    ///
    /// - Returns: Recovery owner address
    func getRecoveryOwnerAddress() throws -> String {
        try self.validatePinLength()
        try self.validatePassphrasePrefixLength()
        try self.fetchSalt()
        try self.validateSaltLength()
        return try self.keyManagareDelegate
            .getRecoveryOwnerAddressFrom(
                passphrasePrefix: self.passphrasePrefix,
                userPin: self.userPin,
                salt: self.salt!
        )
    }
    
    /// Get recovery owner address for new pin
    ///
    /// - Returns: Recovery owner address
    func getRecoveryOwnerAddressForNewPin() -> String? {
        do {
            try self.validateNewPinLength()
            try self.validatePassphrasePrefixLength()
            try self.validateSaltLength()
            try self.fetchSalt()
            return try self.keyManagareDelegate
                .getRecoveryOwnerAddressFrom(
                    passphrasePrefix: self.passphrasePrefix,
                    userPin: self.newUserPin!,
                    salt: self.salt!
            )
        }catch {
            return nil
        }        
    }
    
    /// Clear the stored pin hash
    ///
    /// - Throws: OstError
    func clearPinHash() throws {
        try self.keyManagareDelegate.deletePinHash()
    }

    /// Get signed data for pin reset
    ///
    /// - Parameter newRecoveryOwnerAddress: New recovery owner address
    /// - Returns: SignedData
    /// - Throws: OstError
    func signResetPinData(newRecoveryOwnerAddress: String) throws -> OstKeyManagerDelegate.SignedData {
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wh_pm_srpd_1", .userEntityNotFound)
        }
        if (!user.isStatusActivated) {
            throw OstError("w_wh_pm_srpd_2", .userNotActivated)
        }
        guard let recoveryAddress = user.recoveryAddress else {
            throw OstError("w_wh_pm_srpd_3", .sdkError)
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
        
        let signingHash = try! eip712.getEIP712Hash()
        
        let signedData = try self.keyManagareDelegate
            .signWithRecoveryKey(
                tx: signingHash,
                userPin: self.userPin,
                passphrasePrefix: self.passphrasePrefix,
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
    func signRecoverDeviceData(deviceAddressToRecover: String) throws -> OstKeyManagerDelegate.SignedData {
        try validatePin()
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wh_pm_srdd_1", .userEntityNotFound)
        }
        if (!user.isStatusActivated) {
            throw OstError("w_wh_pm_srdd_2", .userNotActivated)
        }
        guard let recoveryAddress = user.recoveryAddress else {
            throw OstError("w_wh_pm_srdd_3", .sdkError)
        }
        guard let device = try OstDevice.getById(deviceAddressToRecover) else {
            throw OstError("w_wh_pm_srdd_4", .invalidRecoverDeviceAddress)
        }
        if (!device.isStatusAuthorized) {
            throw OstError("w_wh_pm_srdd_6", .invalidRecoverDeviceAddress)
        }
        
        guard let linkedAddress = device.linkedAddress else {
            throw OstError("w_wh_pm_srdd_5", .sdkError)
        }

        guard let currentDevice = user.getCurrentDevice() else {
            throw OstError("w_wh_pm_srdd_6", .deviceNotSet)
        }
        if (!currentDevice.isStatusRegistered) {
            throw OstError("w_wh_pm_srdd_7", .deviceNotSet)
        }
        let typedData = TypedDataForRecovery
            .getInitiateRecoveryTypedData(
                verifyingContract: recoveryAddress,
                prevOwner: linkedAddress,
                oldOwner: deviceAddressToRecover,
                newOwner: currentDevice.address!
        )
        
        let eip712: EIP712 =  EIP712(types: typedData["types"] as! [String: Any],
                                     primaryType: typedData["primaryType"] as! String,
                                     domain: typedData["domain"] as! [String: String],
                                     message: typedData["message"] as! [String: Any])
        
        let signingHash = try eip712.getEIP712Hash()
        
        let signedData = try self.keyManagareDelegate
            .signWithRecoveryKey(
                tx: signingHash,
                userPin: self.userPin,
                passphrasePrefix: self.passphrasePrefix,
                salt: self.salt!
        )
        
        if (user.recoveryOwnerAddress!.caseInsensitiveCompare(signedData.address) != .orderedSame) {
            throw OstError("w_wh_pm_srdd_8", .invalidRecoveryAddress)
        }
        return signedData
    }
    
    /// Get abort device recovery signed data.
    ///
    /// - Parameters:
    ///   - recoveringDevice: Recovering device
    ///   - revokingDevice: Revoking device
    /// - Returns: Signed data
    /// - Throws: OstError
    func signAbortRecoverDeviceData(recoveringDevice: OstDevice,
                                    revokingDevice: OstDevice) throws -> OstKeyManagerDelegate.SignedData {
        
        try validatePin()
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wh_pm_srdd_1", .userEntityNotFound)
        }
        if (!user.isStatusActivated) {
            throw OstError("w_wh_pm_srdd_2", .userNotActivated)
        }
        guard let recoveryAddress = user.recoveryAddress else {
            throw OstError("w_wh_pm_srdd_3", .sdkError)
        }
        
        if !recoveringDevice.isStatusRecovering {
            throw OstError("w_wh_pm_srdd_4", .noPendingRecovery)
        }
        
        if !revokingDevice.isStatusRevoking {
            throw OstError("w_wh_pm_srdd_5", .noPendingRecovery)
        }
        
        guard let linkedAddress = revokingDevice.linkedAddress else {
            throw OstError("w_wh_pm_srdd_6", .linkedAddressNotFound)
        }
        
        let typedData = TypedDataForRecovery
            .getAbortRecoveryTypedData(
                verifyingContract: recoveryAddress,
                prevOwner: linkedAddress,
                oldOwner: revokingDevice.address!,
                newOwner: recoveringDevice.address!
        )
        
        let eip712: EIP712 =  EIP712(types: typedData["types"] as! [String: Any],
                                     primaryType: typedData["primaryType"] as! String,
                                     domain: typedData["domain"] as! [String: String],
                                     message: typedData["message"] as! [String: Any])
        
        let signingHash = try eip712.getEIP712Hash()
        
        let signedData = try self.keyManagareDelegate
            .signWithRecoveryKey(
                tx: signingHash,
                userPin: self.userPin,
                passphrasePrefix: self.passphrasePrefix,
                salt: self.salt!
        )
        
        if (user.recoveryOwnerAddress!.caseInsensitiveCompare(signedData.address) != .orderedSame) {
            throw OstError("w_wh_pm_srdd_8", .invalidRecoveryAddress)
        }
        return signedData
    }
    
    /// Validate salt length
    ///
    /// - Throws: OstError
    private func validateSaltLength() throws {
        try self.fetchSalt()
        
        if self.salt!.count == 0 {
            throw OstError( "w_wh_pm_vsl_1", .invalidAPIResponse);
        }
    }
    
    /// Validate new pin length
    ///
    /// - Throws: OstError
    private func validateNewPinLength() throws {
        if (self.newUserPin == nil
            || OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.newUserPin!.count) {
            
            throw OstError("w_wh_pm_v_1", .invalidNewUserPassphrase);
        }
    }
    /// Validate pin data
    ///
    /// - Throws: OstError
    private func validate() throws{
        try self.validatePinLength()
        try self.validatePassphrasePrefixLength()
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
    
    /// Fetch user
    ///
    /// - Returns: OstUser object
    /// - Throws: OstError
    private func fetchUser() throws -> OstUser {
        let group = DispatchGroup()
        
        var ostUser: OstUser? = nil
        var err: OstError? = nil
        
        group.enter()
        
        try OstAPIUser.init(userId: self.userId)
            .getUser(onSuccess: { (user:OstUser) in
                ostUser = user
                group.leave()
            }, onFailure: { (error:OstError) in
                err = error
                group.leave()
            })
        
        group.wait()
        
        if (err != nil) {
            throw err!
        }
        
        return ostUser!
    }
}
