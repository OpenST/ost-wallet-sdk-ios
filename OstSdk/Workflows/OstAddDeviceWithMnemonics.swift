//
//  OstAddDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

class OstAddDeviceWithMnemonics: OstWorkflowBase, OstValidateDataProtocol {
    private let ostAddDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstAddDevice", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let mnemonicsManager: OstMnemonicsKeyManager
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - mnemonics: Mnemonics provided by user.
    ///   - delegate: Callback.
    init(userId: String,
         mnemonics: [String],
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.mnemonicsManager = OstMnemonicsKeyManager(withMnemonics: mnemonics, andUserId: userId)
        super.init(userId: userId, delegate: delegate)
    }

    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostAddDeviceQueue
    }
    
    /// Validiate basic parameters for workflow
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        if (self.mnemonicsManager.isMnemonicsValid() == false) {
            throw OstError("w_adwm_p_1", .invalidMnemonics)
        }
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceRegistered()
    }
    
    /// process workflow.
    ///
    /// - Throws: OstError
    override func process() throws {
        try fetchDevice()
        verifyData(device: self.currentDevice!)
    }
    
    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        var error: OstError? = nil
        var deviceFromMnemonics: OstDevice? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: userId)
            .getDevice(
                deviceAddress: self.mnemonicsManager.address!,
                onSuccess: { (ostDevice) in
                    deviceFromMnemonics = ostDevice
                    group.leave()
        }) { (ostError) in
            error = ostError
            group.leave()
        }
        group.wait()
        
        if (nil != error) {
             throw error!
        }
        if (!deviceFromMnemonics!.isStatusAuthorized) {
            throw OstError("w_adwm_fd_1", OstErrorText.deviceNotAuthorized)
        }
        if (deviceFromMnemonics!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
            throw OstError("w_adwm_fd_2", OstErrorText.registerSameDevice)
        }
    }
    
    /// verify device from user.
    ///
    /// - Parameter device: OstDevice entity.
    private func verifyData(device: OstDevice) {
        let workflowContext = OstWorkflowContext(workflowType: .addDeviceWithMnemonics);
        let contextEntity: OstContextEntity = OstContextEntity(entity: device, entityType: .device)
        DispatchQueue.main.async {
            self.delegate.verifyData(workflowContext: workflowContext,
                                     ostContextEntity: contextEntity,
                                     delegate: self)
        }
    }
    
    /// Callback from user about data verified to continue.
    public func dataVerified() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            self.authenticateUser()
        }
    }
    
    /// Proceed with workflow after user is authenticated.
    override func proceedWorkflowAfterAuthenticateUser() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
                do {
                    let signature = try self.mnemonicsManager.sign(signingHash)
                    return (signature, self.mnemonicsManager.address)
                }catch {
                    return (nil, nil)
                }
            }
            
            let onSuccess: ((OstDevice) -> Void) = { (ostDevice) in
                self.postWorkflowComplete(entity: ostDevice)
            }
            
            let onFailure: ((OstError) -> Void) = { (error) in
                self.postError(error)
            }
            
            let onRequestAcknowledged: ((OstDevice) -> Void) = { (ostDevice) in
                self.postRequestAcknowledged(entity: ostDevice)
            }
            
            //Get device for address generated from mnemonics.
            OstAuthorizeDevice(userId: self.userId,
                               deviceAddressToAdd: self.currentDevice!.address!,
                               generateSignatureCallback: generateSignatureCallback,
                               onRequestAcknowledged: onRequestAcknowledged,
                               onSuccess: onSuccess,
                               onFailure: onFailure).perform()
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .addDevice)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
