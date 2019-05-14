/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddDeviceWithQRData: OstUserAuthenticatorWorkflow, OstDataDefinitionWorkflow {
    static private let PAYLOAD_DEVICE_ADDRESS_KEY = "da"
    
    class func getAddDeviceParamsFromQRPayload(_ payload: [String: Any?]) throws -> String {
        guard let deviceAddress: String = payload[OstAddDeviceWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY] as? String else {
            throw OstError("w_adwqrd_gadpfqrp_1", .invalidQRCode)
        }
        if deviceAddress.isEmpty {
            throw OstError("w_adwqrd_gadpfqrp_2", .invalidQRCode)
        }
        return deviceAddress
    }
    
    static private let ostAddDeviceWithQRDataQueue = DispatchQueue(label: "com.ost.sdk.OstAddDeviceWithQRData", qos: .userInitiated)
    private let workflowTransactionCountForPolling = 1
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
        
        if !self.deviceAddress.isValidAddress {
            throw OstError("w_adwqrd_fd_1", .wrongDeviceAddress)
        }
        
        if (self.deviceAddress.caseInsensitiveCompare(self.currentDevice!.address!) == .orderedSame){
            throw OstError("w_adwqrd_fd_2", OstErrorText.processSameDevice)
        }
    }
    
    override func onDeviceValidated() throws {
        try fetchDevice()
        try super.onDeviceValidated()
    }
    
    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    func fetchDevice() throws {
        if nil == self.deviceToAdd {
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
    
    /// Authorize device after user authenticated.
    ///
    /// - Throws: OstError
    override func onUserAuthenticated() throws {
        _ = try syncDeviceManager()
        try authorizeDevice()
    }
    
    /// API request for authorize device
    ///
    /// - Parameter params: API parameters for authorize device
    /// - Throws: OstError
    func authorizeDevice() throws {
        
        let authorizeDeviceMangerWithQRSigner = OstKeyManagerGateway
            .getOstAuthorizeDeviceWithQRSigner(userId: self.userId,
                                            deviceAddressToAdd: self.deviceAddress)
        let authorizeDeviceParams = try authorizeDeviceMangerWithQRSigner.getApiParams()
        
        try OstAPIDevice(userId: self.userId)
            .authorizeDevice(params: authorizeDeviceParams,
                             onSuccess: { (ostDevice) in
                                
                                self.postRequestAcknowledged(entity: ostDevice)
                                self.pollingForAuthorizeDevice()
            }) { (error) in
                self.postError(error)
        }
    }
    
    /// Polling for device
    func pollingForAuthorizeDevice() {
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.postWorkflowComplete(entity: ostDevice)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                self.postError(error)
            }
        }
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.deviceAddress,
                                workflowTransactionCount: self.workflowTransactionCountForPolling,
                                successStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                failureStatus: OstDevice.Status.REGISTERED.rawValue,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
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
    
    //MARK: - OstDataDefinitionWorkflow Delegate
    
    /// Get context entity for provided data defination
    ///
    /// - Returns: OstContextEntity
    func getDataDefinitionContextEntity() -> OstContextEntity {
        return self.getContextEntity(for: self.deviceToAdd!)
    }
    
    /// Get workflow context for provided data defination.
    ///
    /// - Returns: OstWorkflowContext
    func getDataDefinitionWorkflowContext() -> OstWorkflowContext {
        return self.getWorkflowContext()
    }

    /// Validate data defination dependent parameters.
    ///
    /// - Throws: OstError
    func validateApiDependentParams() throws {
        try self.fetchDevice()
    }
    
    /// Start data defination flow
    func startDataDefinitionFlow() {
        performState(OstWorkflowStateManager.DEVICE_VALIDATED)
    }
}
