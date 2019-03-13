//
//  OstPolling.swift
//  OstSdk
//
//  Created by aniket ayachit on 28/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstPollingEntityType {
    case user, session, device, transaction
}

class OstPolling: OstWorkflowBase {
    
    static private let ostPollingQueue = DispatchQueue(label: "com.ost.sdk.OstPolling", qos: .background)
    private let workflowTransactionCount = 1
    private let entityId: String
    private let entityType: OstPollingEntityType
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - entityId: entity id.
    ///   - entityType: entity type.
    ///   - delegate: Callback.
    init(userId: String,
         entityId: String,
         entityType: OstPollingEntityType,
         delegate: OstWorkFlowCallbackDelegate) {
        
        self.entityId = entityId
        self.entityType = entityType
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstPolling.ostPollingQueue
    }
    
    /// validate workflow params.
    ///
    /// - Throws: OstError.
    override func validateParams() throws {
        try super.validateParams()
        
        switch self.entityType {
        case .user:
            try self.workFlowValidator!.isUserActivated()
            if (!self.currentUser!.isStatusActivating) {
                throw OstError("w_p_vp_1", OstErrorText.userNotActivating)
            }
        case .device:
            try self.workFlowValidator!.isDeviceAuthorized()
            if (!self.currentDevice!.isStatusRegistered) {
                throw OstError("w_p_vp_2", OstErrorText.deviceNotRegistered)
            }
        case .transaction:
            return
        case .session:
            if let session: OstSession = try OstSession.getById(self.entityId) {
                if (!session.isStatusAuthorizing) {
                    throw OstError("w_p_vp_5", OstErrorText.sessionNotAuthorizing)
                }
            }
        }
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        self.startPollingService()
    }
    
    /// perform specific polling service on the basis of entityType.
    private func startPollingService() {
        
        let onSuccessCallback: ((OstBaseEntity) -> Void) = { (ostBaseEntity) in
            self.postWorkflowComplete(entity: ostBaseEntity)
        }
        
        let onFailureCallback: ((OstError) -> Void) = { (ostError) in
            self.postError(ostError)
        }
        
        let pollingService: OstBasePollingService
        
        switch entityType {
        case .user:
            pollingService = OstUserPollingService(userId: self.userId,
                                                   workflowTransactionCount: workflowTransactionCount,
                                                   successCallback: onSuccessCallback, failureCallback: onFailureCallback)
        case .device:
            pollingService = OstDevicePollingService(userId: self.userId,
                                                     deviceAddress: self.entityId,
                                                     workflowTransactionCount: workflowTransactionCount,
                                                     successStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                                     failureStatus: OstDevice.Status.REGISTERED.rawValue,
                                                     successCallback:onSuccessCallback, failureCallback: onFailureCallback)
        case .session:
            pollingService = OstSessionPollingService(userId: self.userId,
                                                      sessionAddress: self.entityId,
                                                      workflowTransactionCount: workflowTransactionCount,
                                                      successCallback: onSuccessCallback,
                                                      failureCallback: onFailureCallback)
        case .transaction:
            pollingService = OstTransactionPollingService(userId: self.userId,
                                                          transaciotnId: self.entityId,
                                                          workflowTransactionCount: workflowTransactionCount,
                                                          successCallback: onSuccessCallback, failureCallback: onFailureCallback)
        }
        pollingService.perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .polling)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        let contextEntityType: OstEntityType
        switch self.entityType {
        case .device:
            contextEntityType = .device
        case .session:
            contextEntityType = .session
        case .user:
            contextEntityType = .user
        case .transaction:
            contextEntityType = .transaction
        }
        return OstContextEntity(entity: entity, entityType: contextEntityType)
    }
}
