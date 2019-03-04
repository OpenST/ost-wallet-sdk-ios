//
//  OstResetPin.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 28/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstResetPin: OstWorkflowBase {
    let ostResetPinQueue = DispatchQueue(label: "com.ost.sdk.OstResetPin", qos: .background)
    let workflowTransactionCountForPolling = 1
    
    private let newPin: String
    private var validator: OstWorkflowValidator? = nil
    
    init(userId: String,
         password: String,
         oldPin: String,
         newPin: String,
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.newPin = newPin
        super.init(userId: userId, delegate: delegate)
        
        self.appUserPassword = password
        self.uPin = oldPin
    }
    
    override func perform() {
        ostResetPinQueue.async {
            do {
                self.currentUser = try self.getUser()
                let validator = try self.getWorkflowValidator()
                _ = try validator.isDeviceAuthrorized()
                _ = try validator.isUserActivated()
                try validator.validatePinLength(self.newPin)
                let isPinValid = try self.validatePin()
                if (isPinValid == false) {
                    throw OstError("w_rp_p_1", .pinValidationFailed)
                }
                try self.resetPin()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .resetPin)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .recoveryOwner)
    }
    
    private func resetPin() throws {
        try OstKeyManager(userId: self.userId).deletePin()
        
        let salt = try self.getSalt()
        let newRecoveryOwnerAddress = try OstKeyManager(userId: self.userId)
            .getRecoveryOwnerAddressFrom(
                password: self.appUserPassword,
                pin: self.newPin,
                salt: salt
            )
        
        let resetPinSignatureData = try self.signResetPinData(
            newRecoveryOwnerAddress: newRecoveryOwnerAddress,
            salt: salt
        )
        
        let resetPinParams = [
            "new_recovery_owner_address": newRecoveryOwnerAddress,
            "signature": resetPinSignatureData.signature,
            "signer": self.currentUser!.recoveryOwnerAddress,
            "to": self.currentUser!.recoveryAddress
        ]
        
        try OstAPIResetPin(userId: self.userId)
            .changeRecoveryOwner(
                params: resetPinParams as [String : Any],
                onSuccess: { (entity: OstRecoveryOwnerEntity) in
                    self.postRequestAcknowledged(entity: entity)
                    self.pollingForResetPin(entity)
                },
                onFailure: { (error: OstError) in
                    self.postError(error)
                }
            )
    }            
    
    private func signResetPinData(newRecoveryOwnerAddress: String, salt: String) throws -> OstKeyManager.SignedData {
        let typedDataInput: [String: Any] = TypedDataForResetPin
            .getResetPinTypedData(
                verifyingContract: self.currentUser!.recoveryAddress!,
                oldRecoveryOwner: self.currentUser!.recoveryOwnerAddress!,
                newRecoveryOwner: newRecoveryOwnerAddress
        )
        
        let eip712: EIP712 = EIP712(
            types: typedDataInput["types"] as! [String: Any],
            primaryType: typedDataInput["primaryType"] as! String,
            domain: typedDataInput["domain"] as! [String: String],
            message: typedDataInput["message"] as! [String: Any]
        )
        
        let signingHash = try! eip712.getEIP712SignHash()
        
        let signedData = try OstKeyManager(userId: self.userId).signWithRecoveryKey(message: signingHash, pin: self.uPin, password: self.appUserPassword, salt: salt)
        
        if (self.currentUser!.recoveryOwnerAddress == signedData.address) {
            throw OstError("w_rp_rp_1", .invalidRecoveryAddress)
        }

        return signedData
    }
    
    private func pollingForResetPin(_ entity: OstRecoveryOwnerEntity) {
        let successCallback: ((OstRecoveryOwnerEntity) -> Void) = { ostRecoveryOwner in
            self.postWorkflowComplete(entity: ostRecoveryOwner)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstResetPinPollingService(userId: entity.userId!,
                                 recoveryOwnerAddress: entity.address!,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback).perform()
    }
}


