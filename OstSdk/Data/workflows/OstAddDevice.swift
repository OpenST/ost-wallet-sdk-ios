//
//  OstAddDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAddDevice: OstWorkflowBase, OstAddDeviceFlowProtocol, OstStartPollingProtocol {
    let ostAddDeviceThread = DispatchQueue(label: "com.ost.sdk.OstAddDevice", qos: .background)
    
    enum State: Int {
        case INITIALIZE, QR_CODE, ERROR, PIN, WORDS
    }
    var mCurrentState: OstAddDevice.State = .INITIALIZE
    func setCurrentState(_ state: OstAddDevice.State) {
        self.mCurrentState = state
    }
    
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    
    var uPin: String? = nil
    var password: String? = nil
    var wordsArray: [String]? = nil
    var QRCodeImage: UIImage? = nil
    
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
                        self.postError(OstError.actionFailed("User is not present for \(self.userId)."))
                        return
                    }

                    if (!self.user!.isActivated()) {
                        self.postError(OstError.actionFailed("User is not activated for \(self.userId)."))
                        return
                    }

                    self.currentDevice = try self.getCurrentDevice()
                    if (self.currentDevice == nil) {
                        self.postError(OstError.actionFailed("Device is not present for \(self.userId). Plese setup device first by calling OstSdk.setupDevice"))
                        return
                    }

                    if (!self.currentDevice!.isDeviceRegistered()) {
                        self.postError(OstError.actionFailed("Device is not registered for \(self.userId). Plese register device first by calling OstSdk.setupDevice"))
                        return
                    }

                    DispatchQueue.main.async {
                        self.delegate.determineAddDeviceWorkFlow(self)
                        return
                    }
                    
                case .QR_CODE:
                    try self.validateParams()
                    let payload = try self.generateQRCodePayloadForAddDevce()
                    guard let payloadString = try OstUtils.toJSONString(payload) else {
                        throw OstError.actionFailed("Generating QR-Code failed.")
                    }
                    
                    guard let qrCodeCIImage = payloadString.qrCode else {
                        throw OstError.actionFailed("Generating QR-Code image failed.")
                    }
                    self.postFlowComplete(ciImage: qrCodeCIImage)
                    
                case .PIN:
                    try self.validateParams()
                    
                case .WORDS:
                    return
                    
                case .ERROR:
                    self.postError(OstError.actionFailed("Add device flow cancelled."))
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
                throw OstError.invalidInput("User is not created for \(self.userId). Please create user first. Call OstSdk.setupDevice")
            }
            if (!user!.isActivated()) {
                throw OstError.invalidInput("User is not activated for \(self.userId). Please activate user first. Call OstSdk.activateUser")
            }

            let currentDevice = try getCurrentDevice()
            if (currentDevice == nil) {
                throw OstError.invalidInput("Device is not present for \(self.userId). Please create device first.")
            }
            if (!currentDevice!.isDeviceRegistered()) {
                throw OstError.invalidInput("Device is not Registered. Please register device first.")
            }
        case .PIN:
            if (OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > self.uPin!.count) {
                throw OstError.invalidInput("pin should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
            }
            if (OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > self.password!.count) {
                throw OstError.invalidInput("password should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
            }
        case .WORDS:
            let filteredWordsArray = self.wordsArray.flatMap { $0 }
            if (filteredWordsArray!.isEmpty) {
                throw OstError.invalidInput("word list is not appropriate.")
            }
        case .ERROR:
            return
        }
    }
    
    func generateQRCodePayloadForAddDevce() throws  -> [String: String]{
            let currentDevice = try getCurrentDevice()
            return ["data_defination": OstPerform.DataDefination.AUTHORIZE_DEVICE.rawValue,
                    "user_id": self.userId,
                    "device_to_add": currentDevice!.address!]
    }
    
    func postFlowComplete(message: String = "", ciImage: CIImage) {
        Logger.log(message: "OstAddDevice flowComplete", parameterToPrint: nil)
        DispatchQueue.main.async {
            self.delegate.showQR(self, image: ciImage)
        }
    }
    
    //MARK: - Protocol
    public func QRCodeFlow() {
        self.setCurrentState(.QR_CODE)
        perform()
    }
    
    public  func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        self.uPin = uPin
        self.password = appUserPassword
        
        self.setCurrentState(.PIN)
        perform()
    }
    
    public  func walletWordsEntered(_ wordList: Array<String>) {
        self.setCurrentState(.WORDS)
        perform()
    }
    
    func startPolling() {
        
    }
}
