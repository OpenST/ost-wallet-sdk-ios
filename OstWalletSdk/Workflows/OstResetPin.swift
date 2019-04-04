/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstResetPin: OstWorkflowEngine {
    static private let ostResetPinQueue = DispatchQueue(label: "com.ost.sdk.OstResetPin", qos: .userInitiated)
    
    private let workflowTransactionCountForPolling = 1
    private let pinManager: OstPinManager
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - passphrasePrefix: Application Passphrase prefix
    ///   - oldUserPin: Old user pin
    ///   - newUserPin: New user pin
    ///   - delegate: Call back
    init(userId: String,
         passphrasePrefix: String,
         oldUserPin: String,
         newUserPin: String,
         delegate: OstWorkflowDelegate) {

        self.pinManager = OstPinManager(
            userId: userId,
            passphrasePrefix: passphrasePrefix,
            userPin: oldUserPin,
            newUserPin: newUserPin
        )
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstResetPin.ostResetPinQueue
    }
    
    /// Validate params for reset pin
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        try self.pinManager.validateResetPin()
    }
    
    /// Perfrom user device validation
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        try self.workFlowValidator.isUserActivated()
        try self.workFlowValidator.isDeviceAuthorized()
    }
    
    
    /// Reset pin after device validated.
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        let recoveryOwnerEntity = try self.resetPin()
        self.postRequestAcknowledged(entity: recoveryOwnerEntity)
        self.pollingForResetPin(recoveryOwnerEntity)
    }
    
    /// Reset pin
    ///
    /// - Returns: Recovery owner entity object
    /// - Throws: OstError
    private func resetPin() throws -> OstRecoveryOwnerEntity{
        try self.pinManager.validateResetPin()
        
        guard let newRecoveryOwnerAddress = self.pinManager.getRecoveryOwnerAddressForNewPin() else {
            throw OstError("w_rp_rp_1", .recoveryOwnerAddressCreationFailed)
        }
        
        let resetPinSignatureData = try self.pinManager.signResetPinData(
            newRecoveryOwnerAddress: newRecoveryOwnerAddress
        )
        
        guard let user = try OstUser.getById(self.userId) else {
            throw OstError("w_rp_rp_2", .userEntityNotFound)
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
            err = OstError("w_rp_rp_3", .resetPinFailed)
            group.leave()
        }
        group.wait()
        
        if (err != nil) {
            throw err!
        }
        try? self.pinManager.clearPinHash()
        return recoveryOwnerEntity!
    }
    
    /// Polling for reset pin
    ///
    /// - Parameter entity: Recovery owner entity object
    private func pollingForResetPin(_ entity: OstRecoveryOwnerEntity) {
        let successCallback: ((OstRecoveryOwnerEntity) -> Void) = { ostRecoveryOwner in
            OstSdkSync(userId: self.userId, forceSync: true, syncEntites: .User, onCompletion: { (_) in
                self.postWorkflowComplete(entity: ostRecoveryOwner)
            }).perform()
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        // Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstResetPinPollingService(userId: entity.userId!,
                                 recoveryOwnerAddress: entity.address!,
                                 successStatus: OstRecoveryOwnerEntity.Status.AUTHORIZED.rawValue,
                                 failureStatus: OstRecoveryOwnerEntity.Status.AUTHORIZATION_FAILED.rawValue,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback)
            .perform()
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
}


