//
//  OstAddDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

class OstAddDeviceWithMnemonics: OstWorkflowBase {
    let ostAddDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstAddDevice", qos: .background)
    let workflowTransactionCountForPolling = 1
    
    let mnemonicsManager: OstMnemonicsKeyManager
    
    var deviceFromMnemonics: OstDevice? = nil
    
    init(userId: String,
         mnemonics: [String],
         delegate: OstWorkFlowCallbackProtocol) {
        self.mnemonicsManager = OstMnemonicsKeyManager(withMnemonics: mnemonics, andUserId: userId)
        super.init(userId: userId, delegate: delegate)
    }

    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostAddDeviceQueue
    }
    
    override func process() throws {
        try self.fetchDevice()
        self.authorizeDeviceWithMnemonics()
    }
    
    override func validateParams() throws {
        try super.validateParams()
        
        if (self.mnemonicsManager.isMnemonicsValid() == false) {
            throw OstError("w_adwm_p_1", .invalidMnemonics)
        }
        
        if (self.currentUser == nil) {
            throw OstError("w_adwm_p_2", OstErrorText.userNotFound)
        }
        
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_adwm_p_3", OstErrorText.userNotActivated)
        }
        
        if (self.currentDevice == nil) {
            throw OstError("w_adwm_p_4",  OstErrorText.deviceNotset)
        }
        if (!self.currentDevice!.isStatusRegistered) {
            throw OstError("w_adwm_p_5", .deviceNotRegistered)
        }
    }
    
    func fetchDevice() throws {
        var error: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: userId).getDevice(deviceAddress: self.mnemonicsManager.address!, onSuccess: { (ostDevice) in
            self.deviceFromMnemonics = ostDevice
            group.leave()
        }) { (ostError) in
            error = ostError
            group.leave()
        }
        group.wait()
        
        if (nil == error) {
            if (!self.deviceFromMnemonics!.isStatusAuthorized) {
                throw OstError("w_adwm_fd_1", OstErrorText.deviceNotAuthorized)
            }
            if (self.deviceFromMnemonics!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
                throw OstError("w_adwm_fd_2", OstErrorText.registerSameDevice)
            }
        }else {
            throw error!
        }
    }
    
    //MARK: - authorize device
    func authorizeDeviceWithMnemonics() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let signature = try self.mnemonicsManager.sign(signingHash)
                return (signature, self.mnemonicsManager.address)
            }catch let error{
                self.postError(error)
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
        return OstWorkflowContext(workflowType: .addDevice)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
