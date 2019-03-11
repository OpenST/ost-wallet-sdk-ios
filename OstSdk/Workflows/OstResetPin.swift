//
//  OstResetPin.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 28/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstResetPin: OstWorkflowBase {
    private let ostResetPinQueue = DispatchQueue(label: "com.ost.sdk.OstResetPin", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let pinManager: OstPinManager
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - password: Application password
    ///   - oldPin: Old pin
    ///   - newPin: New pin
    ///   - delegate: Call back
    init(userId: String,
         password: String,
         oldPin: String,
         newPin: String,
         delegate: OstWorkFlowCallbackDelegate) {

        self.pinManager = OstPinManager(
            userId: userId,
            password: password,
            pin: oldPin,
            newPin: newPin
        )
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostResetPinQueue
    }
    
    /// Validate params for reset pin
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceAuthorized()
        try self.pinManager.validateResetPin()
    }
    
    /// Process reset pin
    ///
    /// - Throws: OstError
    override func process() throws {
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
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstResetPinPollingService(userId: entity.userId!,
                                 recoveryOwnerAddress: entity.address!,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback).perform()
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


