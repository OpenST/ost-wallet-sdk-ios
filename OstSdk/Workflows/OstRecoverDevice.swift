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
    
    let deviceAddressToRecover: String
    
    var deviceToRecover: OstDevice? = nil
    var signature: String? = nil
    var signer: String? = nil
    
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
    
    /**
     1. initiate recovery
     0. user should be activated state
     1. new device should be in register state.
     2. old device should be in authorized state.
     2.abort recovery
     0. user should be activated state
     1. new device should be in authorizing state.
     2. old device should be in recoving state.
     
     devices = d1, d2, d3(current device)
     
     2. get all device from user.
     3. ask for recover device
     params:
     4. d2 = linked address of device tobe recover
     5. d2 = old device address
     6. d3  = new device address
     7. signer = current user recovery owner address
     8. to = current user recovery address
     8.1 verifyingContract = to
     9. add new typed data
     10. signature = recovery owner address private key
     11.
     
     
     * for abort current user device should be authorizing and old device status should ne recoving.
     polling in case of abort
     */
    override func perform() {
        ostRecoverDeviceThread.async {
            do {
                try self.validateParams()
                
                self.deviceToRecover = try OstDevice.getById(self.deviceAddressToRecover)
                if (nil == self.deviceToRecover) {
                    try self.fetchDevice()
                }else {
                    _ = try self.getSalt()
                    self.generateHash()
                }
            }catch let error {
                self.postError(error)
            }
        }
    }
    
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
    
    func fetchDevice() throws {
        try OstAPIDevice(userId: self.userId)
            .getDevice(deviceAddress: self.deviceAddressToRecover,
                       onSuccess: { (ostDevice) in
                        self.deviceToRecover = ostDevice
                        if (!self.deviceToRecover!.isStatusAuthorized) {
                            self.postError(OstError("w_rd_fd_1", OstErrorText.deviceNotAuthorized))
                            return
                        }
                        self.generateHash()
            }) { (ostError) in
                self.postError(ostError)
        }
    }    
    
    func generateHash() {
        do {
            let typedData = TypedDataForRecovery.getInitiateRecoveryTypedData(verifyingContract: self.currentUser!.recoveryOwnerAddress!,
                                                                              prevOwner: self.deviceToRecover!.linkedAddress!,
                                                                              oldOwner: self.deviceToRecover!.address!,
                                                                              newOwner: self.currentDevice!.address!)
            
            let eip712: EIP712 =  EIP712(types: typedData["types"] as! [String: Any],
                                         primaryType: typedData["primaryType"] as! String,
                                         domain: typedData["domain"] as! [String: String],
                                         message: typedData["message"] as! [String: Any])
            
            let signingHash = try eip712.getEIP712SignHash()
            
        }catch let error {
            self.postError(error)
        }
        
    }
}
