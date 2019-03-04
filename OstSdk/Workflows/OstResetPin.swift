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
    private let pinHandler: OstPinHandler
    
    private var validator: OstWorkflowValidator? = nil
    
    init(userId: String,
         password: String,
         oldPin: String,
         newPin: String,
         delegate: OstWorkFlowCallbackProtocol) {

        self.pinHandler = OstPinHandler(
            userId: userId,
            password: password,
            pin: oldPin,
            newPin: newPin
        )
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostResetPinQueue.async {
            do {
                self.currentUser = try self.getUser()
                let validator = try self.getWorkflowValidator()
                if (!(try validator.isDeviceAuthrorized())) {
                   throw OstError("w_rp_p_1", .deviceNotAuthorized)
                }
                if(!(try validator.isUserActivated())) {
                   throw OstError("w_rp_p_2", .userNotActivated)
                }
                
                let recoveryOwnerEntity = try self.pinHandler.resetPin()
                self.postRequestAcknowledged(entity: recoveryOwnerEntity)
                self.pollingForResetPin(recoveryOwnerEntity)
                
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
}


