/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit


class OstInitiateDeviceRecoveryWorkflowController: OstBaseWorkflowController {
    
    var recoverDeviceAddress: String?
    var deviceListController: OstInitiateRecoveryDLViewController? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - recoverDeviceAddress: Device address to recover
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    init(userId: String,
         recoverDeviceAddress: String?,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.recoverDeviceAddress = recoverDeviceAddress
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
    }
    
    deinit {
        print("OstInitiateDeviceRecoveryWorkflowController :: I am deinit ");
    }
        
    override func performUIActions() {
        if nil == recoverDeviceAddress {
            self.openAuthorizeDeviceListController()
        } else {
            self.openGetPinViewController()
        }
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentUser!.isStatusActivated {
            throw OstError("i_wc_idrwc_pudv_1", .userNotActivated);
        }
      
        if (!self.currentDevice!.isStatusRegistered) {
            throw OstError("i_wc_idrwc_pudv_2", .deviceCanNotBeAuthorized);
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .initiateDeviceRecovery)
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        
        var isFlowCancelled: Bool = false
        if (nil == self.deviceListController && notification.object is OstPinViewController)
            || (nil != self.deviceListController && notification.object is OstInitiateRecoveryDLViewController) {
            
            isFlowCancelled = true
        }
        
        if ( isFlowCancelled ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .initiateDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    func setGetPinViewController() {
        self.getPinViewController = OstPinViewController
            .newInstance(pinInputDelegate: self,
                         pinVCConfig: OstPinVCConfig.getRecoveryAccessPinVCConfig());
    }
    
    func openAuthorizeDeviceListController() {
        
        DispatchQueue.main.async {
            self.deviceListController = OstInitiateRecoveryDLViewController
                .newInstance(userId: self.userId,
                             callBack: {[weak self] (device) in
                                self?.recoverDeviceAddress = (device?["address"] as? String) ?? ""
                                self?.openGetPinViewController()
                })
            
            self.deviceListController!.presentVCWithNavigation()
        }
    }
    
    func openGetPinViewController() {
        DispatchQueue.main.async {
            self.setGetPinViewController()
            if nil == self.deviceListController {
                self.getPinViewController!.presentVCWithNavigation()
            }else {
                self.getPinViewController!.pushViewControllerOn(self.deviceListController!)
            }
        }
    }
    
    //MARK: - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .initiateDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            return;
        }
        
        OstWalletSdk.initiateDeviceRecovery(userId: self.userId,
                                            recoverDeviceAddress: self.recoverDeviceAddress!,
                                            userPin: self.userPin!,
                                            passphrasePrefix: passphrase,
                                            delegate: self)
        self.userPin = nil;
        showLoader(progressText: .initiateDeviceRecovery);
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.deviceListController ) {
            self.deviceListController?.removeViewController(flowEnded: true)
        }
        self.getPinViewController = nil
        self.passphrasePrefixDelegate = nil
        self.deviceListController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc public override func cleanUpPinViewController() {
        self.sdkPinAcceptDelegate = nil;
    }
}
