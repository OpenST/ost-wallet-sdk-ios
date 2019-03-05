//
//  OstRecoverDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
//TODO: Work here.
class OstRecoverDevice: OstWorkflowBase {
    let ostRecoverDeviceThread = DispatchQueue(label: "com.ost.sdk.OstRecoverDevice", qos: .background)
    let workflowTransactionCountForPolling = 1
    let deviceAddressToRecover: String
    
    var deviceToRecover: OstDevice? = nil
    var signature: String? = nil
    var signer: String? = nil
    
    private var pinManager: OstPinManager? = nil;
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - userId: User id from kit.
    ///   - deviceAddressToRecover: device address to revoke.
    ///   - uPin: user pin.
    ///   - password: password of user from application server
    ///   - delegate: Callback.
    init(userId: String,
         deviceAddressToRecover: String,
         uPin: String,
         password: String,
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.deviceAddressToRecover = deviceAddressToRecover
        super.init(userId: userId, delegate: delegate)
        
        self.pinManager = OstPinManager(userId: self.userId, password: password, pin: uPin)
    }
    
    /// perform
    override func perform() {
        ostRecoverDeviceThread.async {
            do {
                try self.validateParams()
                
                self.deviceToRecover = try OstDevice.getById(self.deviceAddressToRecover)
                if (nil == self.deviceToRecover) {
                    try self.fetchDevice()
                }
                //_ = try self.getSalt()
                //self.generateHash()
                let signedData = try self.pinManager?
                    .signRecoverDeviceData(deviceAddressToRecover: self.deviceAddressToRecover)
                self.signer = signedData?.address
                self.signature = signedData?.signature
                try self.recoverDevice()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    /// Validate params.
    ///
    /// - Throws: OstError
    func validateParams() throws {
        self.currentUser = try getUser()
        if (nil == self.currentUser) {
            throw OstError("w_rd_vp_1", OstErrorText.userNotFound)
        }
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_rd_vp_2", OstErrorText.userNotActivated)
        }
        
        self.currentDevice = try getCurrentDevice()
        if (nil == self.currentDevice) {
            throw OstError("w_rd_vp_3", OstErrorText.deviceNotFound)
        }
        if (!self.currentDevice!.isStatusRegistered) {
            throw OstError("w_rd_vp_4", OstErrorText.deviceNotRegistered)
        }
    }
    
    /// Fetch device from kit
    ///
    /// - Throws: OstError
    func fetchDevice() throws {
        try OstAPIDevice(userId: self.userId)
            .getDevice(deviceAddress: self.deviceAddressToRecover,
                       onSuccess: { (ostDevice) in
                        
                        do {
                            self.deviceToRecover = ostDevice
                            if (!self.deviceToRecover!.isStatusAuthorized) {
                                throw OstError("w_rd_fd_1", OstErrorText.deviceNotAuthorized)
                            }
                        } catch let error {
                            self.postError(error)
                        }
                        
            }) { (ostError) in
                self.postError(ostError)
        }
    }
    
    /// Revoke device api call
    ///
    /// - Throws: OstError
    func recoverDevice() throws {
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
