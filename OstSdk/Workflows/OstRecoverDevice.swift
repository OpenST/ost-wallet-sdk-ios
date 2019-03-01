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
        
        self.uPin = uPin
        self.appUserPassword = password
    }
    
    /// perform
    override func perform() {
        ostRecoverDeviceThread.async {
            do {
                try self.validateParams()
                
                self.deviceToRecover = try OstDevice.getById(self.deviceAddressToRecover)
                if (nil == self.deviceToRecover) {
                    try self.fetchDevice()
                }else {
                    self.fetchSalt()
                }
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
                        self.deviceToRecover = ostDevice
                        if (!self.deviceToRecover!.isStatusAuthorized) {
                            self.postError(OstError("w_rd_fd_1", OstErrorText.deviceNotAuthorized))
                            return
                        }
                        self.fetchSalt()
            }) { (ostError) in
                self.postError(ostError)
        }
    }
    
    /// Fetch salt from kit
    override func fetchSalt() {
        do {
            try OstAPISalt(userId: self.userId).getRecoverykeySalt(onSuccess: { (saltResponse) in
                
                self.saltResponse = saltResponse
                self.generateHash()
                
            }, onFailure: { (error) in
                self.postError(error)
            })
        }catch let error{
            self.postError(error)
        }
    }
    
    /// Generate eip712 hash and signature from user recovery owner key
    func generateHash() {
        do {
            let typedData = TypedDataForRecovery.getInitiateRecoveryTypedData(verifyingContract: self.currentUser!.recoveryAddress!,
                                                                              prevOwner: self.deviceToRecover!.linkedAddress!,
                                                                              oldOwner: self.deviceToRecover!.address!,
                                                                              newOwner: self.currentDevice!.address!)
            
            let eip712: EIP712 =  EIP712(types: typedData["types"] as! [String: Any],
                                         primaryType: typedData["primaryType"] as! String,
                                         domain: typedData["domain"] as! [String: String],
                                         message: typedData["message"] as! [String: Any])
            
            let signingHash = try eip712.getEIP712SignHash()
            
            self.signature = try OstKeyManager(userId: self.userId).signWithRecoveryKey(signingHash,
                                                                                        pin: self.uPin,
                                                                                        password: self.appUserPassword,
                                                                                        salt: self.saltResponse!["scrypt_salt"] as! String)
            
            try self.revokeDevice()
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Revoke device api call
    ///
    /// - Throws: OstError
    func revokeDevice() throws {
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
