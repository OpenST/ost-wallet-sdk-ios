/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRecoverDevice: OstWorkflowEngine {
    static private let ostRecoverDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRecoverDevice", qos: .userInitiated)
    private let workflowTransactionCountForPolling = 1
    private let deviceAddressToRecover: String
    private let pinManager: OstPinManager
    
    private var deviceToRecover: OstDevice? = nil
    private var signature: String? = nil
    private var signer: String? = nil

    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddressToRecover: Device address to revoke
    ///   - userPin: User pin
    ///   - passphrasePrefix: Passphrase prefix of user from application server
    ///   - delegate: Callback
    init(userId: String,
         deviceAddressToRecover: String,
         userPin: String,
         passphrasePrefix: String,
         delegate: OstWorkflowDelegate) {
        
        self.deviceAddressToRecover = deviceAddressToRecover
        self.pinManager = OstKeyManagerGateway
            .getOstPinManager(userId: userId,
                              passphrasePrefix: passphrasePrefix,
                              userPin: userPin)
        
         super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstRecoverDevice.ostRecoverDeviceQueue
    }
    
    /// Validate params.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        if !self.deviceAddressToRecover.isValidAddress {
            throw OstError("w_rd_vp_1", OstErrorText.wrongDeviceAddress)
        }
        try self.pinManager.validatePin()
        try self.pinManager.validatePassphrasePrefixLength()
    }
    
    /// Validate user and device
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        try isUserActivated()
        try isDeviceRegistered()
    }
    
    /// Initiate device recovery
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        self.deviceToRecover = try OstDevice.getById(self.deviceAddressToRecover)
        if (nil == self.deviceToRecover) {
            try self.fetchDevice()
        }
        if (!self.deviceToRecover!.isStatusAuthorized) {
            throw OstError("w_rd_p_1", OstErrorText.deviceNotAuthorized)
        }
        
        let signedData = try self.pinManager
            .signRecoverDeviceData(deviceAddressToRecover: self.deviceAddressToRecover)
        
        self.signer = signedData.address
        self.signature = signedData.signature
        try self.initiateDeviceRecovery()
    }
   
    /// Fetch device from OST platform
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        var error: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: userId)
            .getDevice(deviceAddress: self.deviceAddressToRecover, onSuccess: { (ostDevice) in
            self.deviceToRecover = ostDevice
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
    
    /// Recover device api call
    ///
    /// - Throws: OstError
    private func initiateDeviceRecovery() throws {
        var params: [String: Any] = [:]
        params["old_linked_address"] = self.deviceToRecover!.linkedAddress!
        params["old_device_address"] = self.deviceToRecover!.address!
        params["new_device_address"] = self.currentDevice!.address!
        params["signature"] = self.signature!
        params["signer"] = self.currentUser!.recoveryOwnerAddress!
        params["to"] = self.currentUser!.recoveryAddress!
        
        try OstAPIDevice(userId: self.userId)
            .initiateRecoverDevice(params: params,
                                   onSuccess: { (ostDevice) in
                                    self.postWorkflowComplete(entity: ostDevice)
            }, onFailure: { (ostError) in
                self.postError(ostError)
            })
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .initiateDeviceRecovery)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
