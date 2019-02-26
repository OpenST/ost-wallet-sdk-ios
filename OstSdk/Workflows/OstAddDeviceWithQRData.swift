//
//  OstAddDeviceWithQRData.swift
//  OstSdk
//
//  Created by Rachin Kapoor on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAddDeviceWithQRData: OstWorkflowBase, OstValidateDataProtocol {
    let ostAddDeviceWithQRDataThread = DispatchQueue(label: "com.ost.sdk.OstAddDeviceWithQRData", qos: .background)
    
    let qrCodeData: [String: Any?]
    
    var deviceAddress: String? = nil
    
    /// Initialization of OstAddDeviceWithQRData
    ///
    /// - Parameters:
    ///   - userId: Kit user id
    ///   - qrCodeData: QR-Code data
    ///   - delegate:
    init(userId: String, qrCodeData: [String: Any?], delegate: OstWorkFlowCallbackProtocol) {
        self.qrCodeData = qrCodeData
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
    /// - Throws: OstError1
    func validateParams() throws {
        let user = try self.getUser()
        if (nil == user) {
            throw OstError1("w_adwqd_vp_1", .userNotFound)
        }
        if (!user!.isStatusActivated) {
            throw OstError1("w_adwqd_vp_2", .userNotActivated)
        }
        
        let currentDevice = try getCurrentDevice()
        if (nil == currentDevice) {
            throw OstError1("w_adwqd_vp_3", .deviceNotset)
        }
        if (!currentDevice!.isStatusAuthorized) {
            throw OstError1("w_adwqd_vp_4", .deviceNotAuthorized)
        }
        
        guard let _ = qrCodeData["da"] as? String else {
            throw OstError1("w_adwqd_vp_5", .wrongDeviceAddress)
        }
    }
    
    func authorizeDevice() {
        do {
            let deviceAddress = qrCodeData["da"] as! String
            try OstAuthorizeDevice.getDevice(userId: self.userId, addressToAdd: deviceAddress,
                                             onSuccess: { (ostDevice) in
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
                        let privatekey = try keychainManager.getDeviceKey()
                        let signature = try OstCryptoImpls().signTx(signingHash, withPrivatekey: privatekey!)
                        return (signature, deviceAddress)
                    }
                    throw OstError.actionFailed("issue while generating signature.")
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
                               deviceAddressToAdd: self.qrCodeData["da"] as! String,
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
