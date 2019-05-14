/*
Copyright © 2019 OST.com Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation

class OstRevokeDeviceWithQRData: OstUserAuthenticatorWorkflow, OstDataDefinitionWorkflow {

    static private let PAYLOAD_DEVICE_ADDRESS_KEY = "da"

    /// Get revoke device parameters from QR-Code payload.
    ///
    /// - Parameter payload: QR-Code parameter
    /// - Returns: String
    /// - Throws: OstError
    class func getRevokeDeviceParamsFromQRPayload(_ payload: [String: Any?]) throws -> String {
        guard let deviceAddress: String = payload[OstRevokeDeviceWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY] as? String else {
            throw OstError("w_rdwqrd_gadpfqrp_1", .invalidQRCode)
        }
        if deviceAddress.isEmpty {
            throw OstError("w_rdwqrd_gadpfqrp_2", .invalidQRCode)
        }
        return deviceAddress
    }

    static private let ostRevokeDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRevokeDevice", qos: .userInitiated)
    private let workflowTransactionCountForPolling = 1
    private let deviceAddressToRevoke: String

    private var deviceToRevoke: OstDevice? = nil

    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddressToRevoke: Device address to revoke
    ///   - delegate: Callback
    init(userId: String,
         deviceAddressToRevoke: String,
         delegate: OstWorkflowDelegate) {

        self.deviceAddressToRevoke = deviceAddressToRevoke
        super.init(userId: userId, delegate: delegate)
    }

    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstRevokeDeviceWithQRData.ostRevokeDeviceQueue
    }

    /// Validate params.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()

        if !self.deviceAddressToRevoke.isValidAddress {
            throw OstError("w_rdwqrd_fd_1", OstErrorText.wrongDeviceAddress)
        }
        if (self.deviceAddressToRevoke.caseInsensitiveCompare(self.currentDevice!.address!) == .orderedSame){
            throw OstError("w_rdwqrd_fd_2", OstErrorText.processSameDevice)
        }
    }

    /// On workflow validated
    override func onDeviceValidated() throws {
        try self.fetchDevice()
        try super.onDeviceValidated()
    }

    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        if nil == self.deviceToRevoke {
            var error: OstError? = nil
            let group = DispatchGroup()
            group.enter()
            try OstAPIDevice(userId: userId)
                .getDevice(deviceAddress: self.deviceAddressToRevoke,
                           onSuccess: { (ostDevice) in
                            self.deviceToRevoke = ostDevice
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
        
        if (!self.deviceToRevoke!.isStatusAuthorized) {
            throw OstError("w_rdwqrd_fd_1", OstErrorText.deviceNotAuthorized)
        }
        if (self.deviceToRevoke!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
            throw OstError("w_rdwqrd_fd_2", OstErrorText.differentOwnerDevice)
        }
        if (nil == self.deviceToRevoke?.linkedAddress) {
            throw OstError("w_rdwqrd_fd_3", OstErrorText.linkedAddressNotFound)
        }
    }
    
    /// Authorize device after user authenticated.
    override func onUserAuthenticated() throws {
         _ = try syncDeviceManager()
        try revokeDevice()
    }
   
    /// Revoke device
    func revokeDevice() throws {
        let revokeDeviceWithQRSigner = OstKeyManagerGateway
            .getOstRevokeDeviceSigner(userId: self.userId,
                                      linkedAddress: self.deviceToRevoke!.linkedAddress!,
                                      deviceAddressToRevoke: self.deviceToRevoke!.address!)
        let revokeDeviceParams = try revokeDeviceWithQRSigner.getApiParams()
        
        try OstAPIDevice(userId: self.userId)
            .revokeDevice(params: revokeDeviceParams,
                          onSuccess: { (ostDevice) in
                            
                            self.postRequestAcknowledged(entity: ostDevice)
                            self.pollingForRevokeDevice()
            
        }) { (error) in
            self.postError(error)
        }
    }
    
    /// Polling for device
    func pollingForRevokeDevice() {
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.postWorkflowComplete(entity: ostDevice)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            DispatchQueue.init(label: "retryQueue").async {
                self.postError(error)
            }
        }
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.deviceAddressToRevoke,
                                workflowTransactionCount: self.workflowTransactionCountForPolling,
                                successStatus: OstDevice.Status.REVOKED.rawValue,
                                failureStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .revokeDeviceWithQRCode)
    }

    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
    
    //MARK: - OstDataDefinitionWorkflow Delegate
    
    /// Validate data defination dependent parameters.
    ///
    /// - Throws: OstError
    func validateApiDependentParams() throws {
        if (self.deviceAddressToRevoke.caseInsensitiveCompare(self.currentDevice!.address!) == .orderedSame){
            throw OstError("w_rdwqrd_vadp_1", OstErrorText.processSameDevice)
        }
        try self.fetchDevice()
    }
    
    /// Get context entity for provided data defination
    ///
    /// - Returns: OstContextEntity
    func getDataDefinitionContextEntity() -> OstContextEntity {
        return self.getContextEntity(for: self.deviceToRevoke!)
    }
    
    /// Get workflow context for provided data defination.
    ///
    /// - Returns: OstWorkflowContext
    func getDataDefinitionWorkflowContext() -> OstWorkflowContext {
        return self.getWorkflowContext()
    }
    
    /// Start data defination flow
    func startDataDefinitionFlow() {
        performState(OstWorkflowStateManager.DEVICE_VALIDATED)
    }
}

