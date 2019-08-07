/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRevokeDeviceWorkflowController: OstBaseWorkflowController {
    var revokeDeviceAddress: String?
    var deviceListController: OstRevokeDLViewController? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - recoverDeviceAddress: Device address to recover
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    init(userId: String,
         revokeDeviceAddress: String?,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.revokeDeviceAddress = revokeDeviceAddress
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
    }
    
    deinit {
        print("OstRevokeDeviceWorkflowController :: I am deinit");
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("ui_i_wc_rdwc_pudv_1", .deviceNotAuthorized)
        }
    }
    
    override func performUIActions() {
        if nil == revokeDeviceAddress {
            self.openAuthorizedDeviceListController()
        }else {
            onDeviceAddressSet()
        }
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig.getRevokeDevicePinVCConfig()
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .revokeDeviceWithQRCode)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if (nil != self.deviceListController && notification.object is OstRevokeDLViewController) {
            
            self.getPinViewController = nil
            
            self.postFlowInterrupted(error: OstError("ui_i_wc_rdwc_vmfp_1", .userCanceled))
        }
    }
    
    func openAuthorizedDeviceListController() {
        DispatchQueue.main.async {
            self.deviceListController = OstRevokeDLViewController
                .newInstance(userId: self.userId,
                             callBack: {[weak self] (device) in
                                self?.revokeDeviceAddress = (device?["address"] as? String) ?? ""
                                self?.onDeviceAddressSet()
                })
            
            self.deviceListController!.presentVCWithNavigation()
        }
    }
    
    
    override public func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.sdkPinAcceptDelegate = delegate;
        
        progressIndicator?.hide()
        progressIndicator = nil
        
        self.getPinViewController = nil
        
        DispatchQueue.main.async {
            self.getPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: self.getPinVCConfig());
            
            if nil == self.deviceListController {
                self.getPinViewController?.presentVCWithNavigation()
            }else {
                self.getPinViewController?.pushViewControllerOn(self.deviceListController!)
            }
        }
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(progressText: .revokingDevice)
    }
    
    func onDeviceAddressSet() {
        OstWalletSdk.revokeDevice(userId: self.userId,
                                  deviceAddressToRevoke: revokeDeviceAddress!,
                                  delegate: self)
        
        showLoader(progressText: .unknown)
    }
    
    override func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        if error.messageTextCode == OstErrorCodes.OstErrorCode.userCanceled
            && nil == getPinViewController {
                
            super.flowInterrupted(workflowContext: workflowContext, error: error)
        }else {
            progressIndicator?.hide()
            progressIndicator = nil
        }
    }
    
    override func cleanUp() {
        if ( nil != self.deviceListController ) {
            self.deviceListController?.removeViewController(flowEnded: true)
        }else if ( nil != self.getPinViewController )  {
            self.getPinViewController?.removeViewController(flowEnded: true)
        }
        self.getPinViewController = nil
        self.passphrasePrefixDelegate = nil
        self.deviceListController = nil
        NotificationCenter.default.removeObserver(self)
        super.cleanUp()
    }
}
