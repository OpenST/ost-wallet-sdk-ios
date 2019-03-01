//
//  OstAddDeviceWithQRData.swift
//  OstSdk
//
//  Created by Rachin Kapoor on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

let PAYLOAD_DEVICE_ADDRESS_KEY = "da"

class OstAddDeviceWithQRData: OstWorkflowBase, OstValidateDataProtocol {
    let ostAddDeviceWithQRDataThread = DispatchQueue(label: "com.ost.sdk.OstAddDeviceWithQRData", qos: .background)
    
    class func getAddDeviceParamsFromQRPayload(_ payload: [String: Any?]) throws -> String {
        guard let deviceAddress: String = payload[PAYLOAD_DEVICE_ADDRESS_KEY] as? String else {
            throw OstError("w_adwqrd_gadpfqrp_1", .invalidQRCode)
        }
        return deviceAddress
    }

    let deviceAddress: String
    /// Initialization of OstAddDeviceWithQRData
    ///
    /// - Parameters:
    ///   - userId: Kit user id
    ///   - qrCodeData: QR-Code data
    ///   - delegate:
    init(userId: String, deviceAddress: String, delegate: OstWorkFlowCallbackProtocol) {
        self.deviceAddress = deviceAddress
        super.init(userId: userId, delegate: delegate)
    }
    
    /// perform
    override func perform() {
        ostAddDeviceWithQRDataThread.async {
            do {
                try self.validateParams()
                self.authorizeDevice()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    /// valdiate parameters
    ///
    /// - Throws: OstError
    func validateParams() throws {
        let user = try self.getUser()
        if (nil == user) {
            throw OstError("w_adwqd_vp_1", .userNotFound)
        }
        if (!user!.isStatusActivated) {
            throw OstError("w_adwqd_vp_2", .userNotActivated)
        }
        
        self.currentDevice = try getCurrentDevice()
        if (nil == self.currentDevice) {
            throw OstError("w_adwqd_vp_3", .deviceNotset)
        }
        if (!self.currentDevice!.isStatusAuthorized) {
            throw OstError("w_adwqd_vp_4", .deviceNotAuthorized)
        }
    }
    
    func authorizeDevice() {
        do {
            try OstAuthorizeDevice.getDevice(userId: self.userId, addressToAdd: self.deviceAddress,
                                             onSuccess: { (ostDevice) in
                                                do {
                                                    if (!ostDevice.isStatusRegistered) {
                                                        throw OstError("w_adwm_fd_1", OstErrorText.deviceNotAuthorized)
                                                    }
                                                    if (ostDevice.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) == .orderedSame){
                                                        throw OstError("w_adwm_fd_2", OstErrorText.registerSameDevice)
                                                    }
                                                }catch let error {
                                                    self.postError(error)
                                                }
                                                self.verifyData(device: ostDevice)
            }) { (ostError) in
                self.postError(ostError)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func verifyData(device: OstDevice) {
        let workflowContext = OstWorkflowContext(workflowType: .addDeviceWithQRCode);
        let contextEntity: OstContextEntity = OstContextEntity(entity: device, entityType: .device)
        self.delegate.verifyData(workflowContext: workflowContext,
                                 ostContextEntity: contextEntity,
                                 delegate: self)
    }
    func dataVerified() {
        self.authenticateUser();
    }
    
    override func proceedWorkflowAfterAuthenticateUser() {
        ostAddDeviceWithQRDataThread.async {
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
        return OstWorkflowContext(workflowType: .addDeviceWithQRCode)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
