/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddDeviceWithQRData: OstWorkflowBase, OstValidateDataDelegate {
    static private let PAYLOAD_DEVICE_ADDRESS_KEY = "da"
    
    class func getAddDeviceParamsFromQRPayload(_ payload: [String: Any?]) throws -> String {
        guard let deviceAddress: String = payload[OstAddDeviceWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY] as? String else {
            throw OstError("w_adwqrd_gadpfqrp_1", .invalidQRCode)
        }
        if !deviceAddress.isValidAddress {
            throw OstError("w_adwqrd_gadpfqrp_2", .invalidQRCode)
        }
        return deviceAddress
    }
    
    static private let ostAddDeviceWithQRDataQueue = DispatchQueue(label: "com.ost.sdk.OstAddDeviceWithQRData", qos: .userInitiated)
    private let deviceAddress: String
    
    private var deviceToAdd: OstDevice? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - qrCodeData: QR-Code data
    ///   - delegate: Callback
    init(userId: String,
         deviceAddress: String,
         delegate: OstWorkflowDelegate) {
        
        self.deviceAddress = deviceAddress
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstAddDeviceWithQRData.ostAddDeviceWithQRDataQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceAuthorized()
        
        if (self.deviceAddress.caseInsensitiveCompare(self.currentDevice!.address!) == .orderedSame){
            throw OstError("w_adwqrd_fd_2", OstErrorText.processSameDevice)
        }
    }
    
    /// process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
        try self.fetchDevice()
        verifyData()
    }
    
    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        var error: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: userId)
            .getDevice(deviceAddress: self.deviceAddress,
                       onSuccess: { (ostDevice) in
                        self.deviceToAdd = ostDevice
                        group.leave()
            }) { (ostError) in
                error = ostError
                group.leave()
        }
        group.wait()
        
        if (nil != error) {
            throw error!
        }
        if (self.deviceToAdd!.isStatusAuthorized) {
            throw OstError("w_adwqrd_fd_1", OstErrorText.deviceAuthorized)
        }
        if (!self.deviceToAdd!.isStatusRegistered) {
            throw OstError("w_adwqrd_fd_1", OstErrorText.deviceNotRegistered)
        }
        
        if (self.deviceToAdd!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
            throw OstError("w_adwqrd_fd_2", OstErrorText.differentOwnerDevice)
        }
    }
    
    /// verify device from user.
    ///
    /// - Parameter device: OstDevice entity.
    private func verifyData() {
        let workflowContext = OstWorkflowContext(workflowType: .authorizeDeviceWithQRCode);
        let contextEntity: OstContextEntity = OstContextEntity(entity: self.deviceToAdd!, entityType: .device)
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
            self.authenticateUser();
        }
    }
    
    /// Proceed with workflow after user is authenticated.
    override func proceedWorkflowAfterAuthenticateUser() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
                do {
                    let keychainManager = OstKeyManager(userId: self.userId)
                    if let deviceAddress = keychainManager.getDeviceAddress() {
                        let signature = try keychainManager.signWithDeviceKey(signingHash)
                        return (signature, deviceAddress)
                    }
                    throw OstError("w_adwqd_pwfaau_1", .apiSignatureGenerationFailed);
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
            
            OstAuthorizeDevice(userId: self.userId,
                               deviceAddressToAdd: self.deviceAddress,
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
        return OstWorkflowContext(workflowType: .authorizeDeviceWithQRCode)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
