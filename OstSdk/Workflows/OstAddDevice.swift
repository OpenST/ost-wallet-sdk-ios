//
//  OstAddDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

class OstAddDevice: OstWorkflowBase, OstAddDeviceFlowProtocol, OstStartPollingProtocol {
    let ostAddDeviceThread = DispatchQueue(label: "com.ost.sdk.OstAddDevice", qos: .background)
    let workflowTransactionCountForPolling = 1

    enum State: Int {
        case INITIALIZE, QR_CODE, ERROR, PIN, WORDS
    }
    var mCurrentState: OstAddDevice.State = .INITIALIZE
    func setCurrentState(_ state: OstAddDevice.State) {
        self.mCurrentState = state
    }
    
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    
    var wordsArray: [String]? = nil
    
    override init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        super.init(userId: userId, delegate: delegate)
    }
    
    /*
     * To Add device using QR
     * Device B to be added
     * 1.Validations
     *  1.1 Device should be registered
     *  1.2 User should be Activated.
     * 2. Ask App for flow
     *  2.1 QR Code
     *      2.1.1 generate multi sig code
     *      2.1.2 start polling
     *  2.2 Pin(Recovery address)
     *  2.3 12 Words
     *
     *
     * Device A which will add
     * 1. Scan QR code
     * 2. Sign with wallet key
     * 3. approve
     */
    override func perform() {
        ostAddDeviceThread.async {
            do {
                switch self.mCurrentState {
                case .INITIALIZE:
                    try self.validateParams()
                    
                    self.user = try self.getUser()
                    if (self.user == nil) {
                        self.postError(OstError.init("w_ad_p_1", "User is not present for \(self.userId)."))
                        return
                    }
                    if (!self.user!.isStatusActivated) {
                        self.postError(OstError.init("w_ad_p_2", "User is not activated for \(self.userId)."))
                        return
                    }
                    
                    self.currentDevice = try self.getCurrentDevice()
                    if (self.currentDevice == nil) {
                        self.postError(OstError.init("w_ad_p_3", "Device is not present for \(self.userId). Plese setup device first by calling OstSdk.setupDevice."))
                        return
                    }
                    
                    if (!self.currentDevice!.isDeviceRegistered()) {
                        self.postError(OstError.init("w_ad_p_4", "Device is not registered for \(self.userId). Plese register device first by calling OstSdk.setupDevice."))
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.delegate.determineAddDeviceWorkFlow(self)
                    }
                    
                case .QR_CODE:
                    try self.validateParams()
                    self.authenticateUser()
                case .PIN:
                    try self.validateParams()
                    
                case .WORDS:
                    self.authorizeDeviceWothMnemonics()
                case .ERROR:
                    self.postError(OstError.init("w_ad_p_3", .addDeviceFlowCancelled))
                }
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        switch self.mCurrentState {
        case .INITIALIZE:
            return
            
        case .QR_CODE:
            let user = try self.getUser()
            if (user == nil) {
                throw OstError.init("w_ad_vp_1", "User is not created for \(self.userId). Please create user first. Call OstSdk.setupDevice")
            }
            if (!user!.isStatusActivated) {
                throw OstError.init("w_ad_vp_2", "User is not activated for \(self.userId). Please activate user first. Call OstSdk.activateUser")
            }
            
            let currentDevice = try getCurrentDevice()
            if (currentDevice == nil) {
                throw OstError.init("w_ad_vp_3", "Device is not present for \(self.userId). Please create device first.")
            }
            if (!currentDevice!.isDeviceRegistered()) {
                throw OstError.init("w_ad_vp_4", "Device is not Registered. Please register device first.")
            }
        case .PIN:
            if (OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.uPin.count) {
                throw OstError.init("w_ad_vp_5", "Pin should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
            }
            if (OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.appUserPassword.count) {
                throw OstError.init("w_ad_vp_6", "Password should be of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
            }
        case .WORDS:
            let filteredWordsArray = self.wordsArray.flatMap { $0 }
            if (filteredWordsArray!.isEmpty) {
                throw OstError.init("w_ad_vp_7", "Word list is not appropriate.")
            }
        case .ERROR:
            return
        }
    }
    
    
    override func proceedWorkflowAfterAuthenticateUser() {
        switch mCurrentState {
        case .QR_CODE:
            do {
                let payload = try self.generateQRCodePayloadForAddDevce()
                guard let payloadString = try OstUtils.toJSONString(payload) else {
                    throw OstError("w_ad_pwaau_1", .qrCodeGenerationFailed)
                }
                
                guard let qrCodeCIImage = payloadString.qrCode else {
                    throw OstError("w_ad_pwaau_2", .qrCodeImageGenerationFailed)
                }
                DispatchQueue.main.async {
                    self.delegate.showQR(self, image: qrCodeCIImage)
                    self.postWorkflowComplete(entity: qrCodeCIImage)
                }
            }catch let error{
                // TODO: Confirm if this is OSTError instance.
                self.postError(error)
            }
        default:
            self.postError(OstError("w_ad_pwaau_3", .unexpectedState))
        }
    }
    
    //MARK: - QR-Code
    func generateQRCodePayloadForAddDevce() throws  -> [String: String]{
        let currentDevice = try getCurrentDevice()
        return ["data_defination": OstPerform.DataDefination.AUTHORIZE_DEVICE.rawValue,
                "user_id": self.userId,
                "device_address": currentDevice!.address!]
    }
    
    
    //MARK: - authorize device
    func authorizeDeviceWothMnemonics() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let cryptoImpl = OstCryptoImpls()
                let ostWalletKeys: OstWalletKeys = try cryptoImpl.generateEthereumKeys(withMnemonics: self.wordsArray!)
                let signature = try cryptoImpl.signTx(signingHash, withPrivatekey: ostWalletKeys.privateKey!)
                return (signature, ostWalletKeys.address!)
            }catch let error{
                self.postError(error)
                return (nil, nil)
            }
        }
        
        let onSuccess: ((OstDevice) -> Void) = { (ostDevice) in
            self.startPolling()
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            self.postError(error)
        }
        
        OstAuthorizeDevice(userId: self.userId,
                           deviceAddressToAdd: self.currentDevice!.address!,
                           generateSignatureCallback: generateSignatureCallback,
                           onSuccess: onSuccess,
                           onFailure: onFailure).perform()
    }
    
    //MARK: - Protocol
    public func QRCodeFlow() {
        self.setCurrentState(.QR_CODE)
        perform()
    }
    
    public override func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        switch mCurrentState {
        case .QR_CODE:
            super.pinEntered(uPin, applicationPassword: appUserPassword)
        default:
            self.uPin = uPin
            self.appUserPassword = appUserPassword
            
            self.setCurrentState(.PIN)
            perform()
        }
    }
    
    public  func walletWordsEntered(_ wordList: String) {
        self.wordsArray = []
        for word in wordList.split(separator: " ") {
            self.wordsArray!.append("\(word)")
        }
        
        self.setCurrentState(.WORDS)
        perform()
    }
    
    func startPolling() {
        switch self.mCurrentState {
        case .PIN:
            return
        case .QR_CODE:
            return
        case .WORDS:
            self.pollingForAddDeviceWithWords()
            return
        default:
            return
        }
    }
    
    func pollingForAddDeviceWithWords() {
        
        let successCallback: ((OstDevice) -> Void) = { ostDevice in
            self.postWorkflowComplete(entity: ostDevice)
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstDevicePollingService(userId: self.userId, deviceAddress: self.currentDevice!.address!, workflowTransactionCount: workflowTransactionCountForPolling, successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        
        switch mCurrentState {
        case .QR_CODE:
            return OstWorkflowContext(workflowType: .showQRCode)
        default:
            return OstWorkflowContext(workflowType: .addDevice)
        }
       
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        switch mCurrentState {
        case .QR_CODE:
            return OstContextEntity(entity: entity, entityType: .ciimage)
        default:
            return OstContextEntity(entity: entity, entityType: .device)
        }
    }
}
