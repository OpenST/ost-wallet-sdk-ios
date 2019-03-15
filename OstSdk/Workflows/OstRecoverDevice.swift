//
//  OstRecoverDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRecoverDevice: OstWorkflowBase {
    static private let ostRecoverDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRecoverDevice", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let deviceAddressToRecover: String
    
    private var deviceToRecover: OstDevice? = nil
    private var signature: String? = nil
    private var signer: String? = nil
    
    private var pinManager: OstPinManager? = nil;
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - userId: User id from kit.
    ///   - deviceAddressToRecover: device address to revoke.
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Passphrase prefix of user from application server
    ///   - delegate: Callback.
    init(userId: String,
         deviceAddressToRecover: String,
         userPin: String,
         passphrasePrefix: String,
         delegate: OstWorkFlowCallbackDelegate) {
        
        self.deviceAddressToRecover = deviceAddressToRecover
        super.init(userId: userId, delegate: delegate)
        
        self.pinManager = OstPinManager(userId: self.userId,
                                        passphrasePrefix: passphrasePrefix,
                                        userPin: userPin)
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
        
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceRegistered()
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        self.deviceToRecover = try OstDevice.getById(self.deviceAddressToRecover)
        if (nil == self.deviceToRecover) {
            try self.fetchDevice()
        }
        if (!self.deviceToRecover!.isStatusAuthorized) {
            throw OstError("w_rd_p_1", OstErrorText.deviceNotAuthorized)
        }
        
        let signedData = try self.pinManager?
            .signRecoverDeviceData(deviceAddressToRecover: self.deviceAddressToRecover)
        self.signer = signedData?.address
        self.signature = signedData?.signature
        try self.recoverDevice()
    }
    
    /// Fetch device from kit
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
    private func recoverDevice() throws {
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
        return OstWorkflowContext(workflowType: .recoverDevice)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
