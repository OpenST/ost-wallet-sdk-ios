//
//  OstAbortDeviceRecovery.swift
//  OstWalletSdk
//
//  Created by aniket ayachit on 21/03/19.
//  Copyright © 2019 OST.com Inc. All rights reserved.
//

import Foundation

class OstAbortDeviceRecovery: OstWorkflowBase {
    static private let ostAbortDeviceRecoveryQueue = DispatchQueue(label: "com.ost.sdk.OstAbortDeviceRecovery", qos: .background)
    private let workflowTransactionCountForPolling = 1
    
    private var pinManager: OstPinManager? = nil
    private var signature: String? = nil
    private var signer: String? = nil
    private var recoveringDevice: OstDevice? = nil
    private var revokingDevice: OstDevice? = nil
    
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
         delegate: OstWorkflowDelegate) {
        
        super.init(userId: userId, delegate: delegate)
        self.pinManager = OstPinManager(userId: self.userId,
                                        passphrasePrefix: password,
                                        userPin: uPin)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstAbortDeviceRecovery.ostAbortDeviceRecoveryQueue
    }
    
    /// process
    ///
    /// - Throws: OstError
    override func process() throws {
        try fetchPendingRecovery()
        
        let signedData = try self.pinManager!
            .signAbortRecoverDeviceData(recoveringDevice: self.recoveringDevice!,
                                        revokingDevice: self.revokingDevice!)
        
        self.signer = signedData.address
        self.signature = signedData.signature
        try self.abortRecoverDevice()
    }
    
    /// Fetch pending recovery devices from server
    ///
    /// - Throws: OstError
    fileprivate func fetchPendingRecovery() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: self.userId)
            .getPendingRecovery(onSuccess: { (devices) in
                
                let assignDevice: ((OstDevice) -> Void) = { device in
                    if device.isStatusRevoking {
                        self.revokingDevice = device
                    }else if device.isStatusRecovering {
                        self.recoveringDevice = device
                    }
                }
                
                if let device1 = devices.first {
                    assignDevice(device1)
                }
                
                if let device2 = devices.last {
                    assignDevice(device2)
                }
                group.leave()
            }, onFailure: { (ostError) in
                err = ostError
                group.leave()
            })
        
        group.wait()
        if (nil != err) {
            throw err!
        }
        
        if (nil == self.recoveringDevice
            || nil == self.revokingDevice) {
            throw OstError("w_ard_fpr_1", OstErrorText.insufficientData)
        }
    }
    
    /// Abort recover device
    ///
    /// - Throws: OstError
    fileprivate func abortRecoverDevice() throws {
        var params: [String: Any] = [:]
        params["old_linked_address"] = self.revokingDevice!.linkedAddress!
        params["old_device_address"] = self.revokingDevice!.address!
        params["new_device_address"] = self.recoveringDevice!.address!
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
    
    /// Polling for checking transaction status
    fileprivate func pollingForAbortRecover(device: OstDevice) {
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            let queue = self.getWorkflowQueue()
            queue.async {
                try? self.fetchRevokingDevice()
                self.postWorkflowComplete(entity: ostDevice)
            }
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        
        OstDevicePollingService(
            userId: self.userId,
            deviceAddress: self.recoveringDevice!.address!,
            workflowTransactionCount: workflowTransactionCountForPolling,
            successStatus: OstDevice.Status.REGISTERED.rawValue,
            failureStatus: OstDevice.Status.AUTHORIZED.rawValue,
            successCallback: successCallback,
            failureCallback: failureCallback).perform()
    }
    
    /// Fetch revoking device entity
    ///
    /// - Throws: OstError
    fileprivate func fetchRevokingDevice() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        
        try OstAPIDevice(userId: self.userId)
            .getDevice(deviceAddress: self.revokingDevice!.address!,
                       onSuccess: { (_) in
                        
                        group.leave()
            }, onFailure: { (ostError) in
                err = ostError
                group.leave()
            })
        group.wait()
        
        if(nil != err) {
            throw err!
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .abortDeviceRecovery)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
