//
//  OstAbortRecoverDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAbortRecoverDevice: OstWorkflowBase {
    private let ostAbortRecoverDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstAbortRecoverDevice", qos: .background)
    private let workflowTransactionCountForPolling = 1
    
    private var deviceAddressToAbort: String? = nil
    private var deviceAddressOfRecovering: String? = nil
    private var linkedAddress: String? = nil
    private var pinManager: OstPinManager? = nil
    private var signature: String? = nil
    private var signer: String? = nil

    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - uPin: User pin
    ///   - password: Application password
    ///   - delegate: Call back
    init(userId: String,
         uPin: String,
         password: String,
         delegate: OstWorkFlowCallbackDelegate) {
        
        super.init(userId: userId, delegate: delegate)
        self.pinManager = OstPinManager(userId: self.userId, password: password, pin: uPin)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostAbortRecoverDeviceQueue
    }
    
    /// Validate params.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        try self.workFlowValidator!.isUserActivated()
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        //TODO: add api call and get devices. Yet to be implemented.
        self.deviceAddressToAbort = "0x5e772eebe89eb3e5e6c446ba42ec7c7ea42df488"
        self.deviceAddressOfRecovering = self.currentDevice!.address!
        self.linkedAddress = "0x0000000000000000000000000000000000000001"
        
        let signedData = try self.pinManager!.signAbortRecoverDeviceData(deviceAddressToRecover: self.deviceAddressToAbort!)
        self.signer = signedData.address
        self.signature = signedData.signature
        try self.abortRecoverDevice()
    }
    
    /// Abort recover device
    ///
    /// - Throws: OstError
    private func abortRecoverDevice() throws {
        var params: [String: Any] = [:]
        params["old_linked_address"] = self.linkedAddress!
        params["old_device_address"] = self.deviceAddressToAbort!
        params["new_device_address"] = self.deviceAddressOfRecovering!
        params["signature"] = self.signature!
        params["signer"] = self.currentUser!.recoveryOwnerAddress!
        params["to"] = self.currentUser!.recoveryAddress!
        
        try OstAPIDevice(userId: self.userId)
            .abortRecoverDevice(
                params: params,
                onSuccess: { (ostDevice) in
            
                    self.postRequestAcknowledged(entity: ostDevice)
                    self.pollingForAbortRecover(device: ostDevice)
            }, onFailure: { (ostError) in
                self.postError(ostError)
            })
    }
    
    //TODO: Implement polling.
    /// Polling for checking transaction status
    func pollingForAbortRecover(device: OstDevice) {
        
    }
        
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .abortRecoverDevice)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
