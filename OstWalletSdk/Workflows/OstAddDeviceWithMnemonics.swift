/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class OstAddDeviceWithMnemonics: OstUserAuthenticatorWorkflow {
    
    static private let ostAddDeviceWithMnemonicsQueue = DispatchQueue(label: "com.ost.sdk.OstAddDeviceWithMnemonics", qos: .userInitiated)
    private let workflowTransactionCountForPolling = 1
    private let mnemonicsManager: OstMnemonicsKeyManager
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - mnemonics: Mnemonics provided by user
    ///   - delegate: Callback
    init(userId: String,
         mnemonics: [String],
         delegate: OstWorkflowDelegate) {
        
        self.mnemonicsManager = OstMnemonicsKeyManager(withMnemonics: mnemonics, andUserId: userId)
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstAddDeviceWithMnemonics.ostAddDeviceWithMnemonicsQueue
    }
    
    /// Validiate basic parameters for workflow
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        if (self.mnemonicsManager.isMnemonicsValid() == false) {
            throw OstError("w_adwm_p_1", .invalidMnemonics)
        }
        
        if (self.currentDevice!.isStatusAuthorized) {
            throw OstError("w_adwm_p_2", .deviceAuthorized)
        } 
    }
    
    /// Validate device as per workflow
    ///
    /// - Throws: OstError
    override func validateDeviceForWorkflow() throws{
        try self.workFlowValidator.isDeviceRegistered()
    }
    
    /// Fetch device after device validated
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        try fetchDevice()
        try super.onDeviceValidated()
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
            throw OstError("w_adwm_fd_2", OstErrorText.differentOwnerDevice)
        }
    }
    
    /// Authorize device after user authenticated.
    override func onUserAuthenticated() {
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
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .authorizeDeviceWithMnemonics)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
