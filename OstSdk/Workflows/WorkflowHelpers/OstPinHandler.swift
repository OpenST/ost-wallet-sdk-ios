//
//  OstPinHandler.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 04/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstPinHandler {
    private let ostPinHandlerQueue = DispatchQueue(label: "OstPinHandler", qos: .background)
    
    private let userId: String
    private let password: String
    private let pin: String
    private var newPin: String? = nil
    private var salt: String? = nil
    
    init(userId: String,
         password: String,
         pin: String,
         newPin: String? = "") {
        
        self.userId = userId
        self.password = password
        self.pin = pin
        self.newPin = newPin
    }
    
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
    
    func resetPin() throws -> OstRecoveryOwnerEntity{
        if (self.newPin == nil || OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.newPin!.count) {
            throw OstError.init(
                "w_wh_ph_v_1",
                "New pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)"
            )
        }
        if (try validatePin()) {
            try OstKeyManager(userId: self.userId).deletePin()
            
            let newRecoveryOwnerAddress = try OstKeyManager(userId: self.userId)
                .getRecoveryOwnerAddressFrom(
                    password: self.password,
                    pin: self.newPin!,
                    salt: self.salt!
            )
            
            let resetPinSignatureData = try self.signResetPinData(
                newRecoveryOwnerAddress: newRecoveryOwnerAddress,
                salt: salt!
            )
            
            guard let user = try OstUser.getById(self.userId) else {
                throw OstError("w_wv_vp_1", .userEntityNotFound)
            }
            let resetPinParams = [
                "new_recovery_owner_address": newRecoveryOwnerAddress,
                "signature": resetPinSignatureData.signature,
                "signer": user.recoveryOwnerAddress,
                "to": user.recoveryAddress
            ]
            
            var recoveryOwnerEntity: OstRecoveryOwnerEntity?
            var err: OstError? = nil
            let group = DispatchGroup()
            group.enter()
            ostPinHandlerQueue.async {
                do {
                    try OstAPIResetPin(userId: self.userId)
                        .changeRecoveryOwner(
                            params: resetPinParams as [String : Any],
                            onSuccess: { (entity: OstRecoveryOwnerEntity) in
                                recoveryOwnerEntity = entity
                                group.leave()
                        },
                            onFailure: { (error: OstError) in
                                err = error
                                group.leave()
                        }
                    )
                } catch {
                    err = OstError("w_wh_ph_rp_1", .resetPinFailed)
                    group.leave()
                }
            }
            group.wait()
            
            if (err != nil) {
                throw err!
            }
            return recoveryOwnerEntity!
        } else {
            throw OstError("w_wv_vp_2", .pinValidationFailed)
        }
    }
    
    private func validate() throws{
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.pin.count {
            throw OstError.init(
                "w_wh_ph_v_2",
                "New pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)"
            )
        }
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > password.count {
            throw OstError.init(
                "w_wh_ph_v_3",
                "Password must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)"
            )
        }
        
        try self.fetchSalt()
        
        if self.salt!.count == 0 {
            throw OstError.init(
                "w_wh_ph_v_4",
                "Invalid salt"
            )
        }
    }
    
    private func fetchSalt() throws{
        if (self.salt == nil) {
            let group = DispatchGroup()
            
            var salt: [String: Any]?
            var err: OstError? = nil
            group.enter()
            ostPinHandlerQueue.async {
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
    
    private func signResetPinData(newRecoveryOwnerAddress: String, salt: String) throws -> OstKeyManager.SignedData {
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_wv_vp_1", .userEntityNotFound)
        }
        let typedDataInput: [String: Any] = TypedDataForResetPin
            .getResetPinTypedData(
                verifyingContract: user.recoveryAddress!,
                oldRecoveryOwner: user.recoveryOwnerAddress!,
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
            throw OstError("w_rp_rp_1", .invalidRecoveryAddress)
        }
        
        return signedData
    }
}
