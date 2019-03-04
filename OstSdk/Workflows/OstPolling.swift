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
    
    let ostPollingThread = DispatchQueue(label: "com.ost.sdk.OstPolling", qos: .background)
    
    let workflowTransactionCount = 1
    let entityId: String
    let entityType: OstPollingEntityType
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - entityId: entity id.
    ///   - entityType: entity type.
    ///   - delegate: Callback.
    init(userId: String, entityId: String, entityType: OstPollingEntityType, delegate: OstWorkFlowCallbackProtocol) {
        self.entityId = entityId
        self.entityType = entityType
        super.init(userId: userId, delegate: delegate)
    }
    
    /// perform
    override func perform() {
        ostPollingThread.async {
            do {
                try self.validateParams()
                self.startPollingService()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    /// perform specific polling service on the basis of entityType.
    func startPollingService() {
        
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

/// valdiate params
extension OstPolling {
    
    /// validate workflow params.
    ///
    /// - Throws: OstError.
    func validateParams() throws {
        self.currentUser = try getUser()
        if (nil == self.currentUser) {
            throw OstError("w_p_vp_1", .userNotFound)
        }
        
        self.currentDevice = try getCurrentDevice()
        if (nil == self.currentDevice) {
            throw OstError("w_p_vp_2", .deviceNotFound)
        }
        
        switch self.entityType {
        case .user:
            if (self.currentUser!.isStatusActivated) {
                throw OstError("w_p_vp_3", OstErrorText.userAlreadyActivated)
            }
            if (!self.currentUser!.isStatusActivating) {
                throw OstError("w_p_vp_4", OstErrorText.userNotActivating)
            }
        case .device:
            if (self.currentDevice!.isStatusAuthorized) {
                throw OstError("w_p_vp_5", OstErrorText.deviceAlreadyAuthorized)
            }
            if (!self.currentDevice!.isStatusAuthorizing) {
                throw OstError("w_p_vp_5", OstErrorText.deviceNotAuthorizing)
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
    
}

