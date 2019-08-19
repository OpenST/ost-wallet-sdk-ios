/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstAbortDeviceRecoveryWorkflowController: OstBaseWorkflowController {
    
    /// Mark - View Controllers.
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc 
    override init(userId: String,
                  passphrasePrefixDelegate:OstPassphrasePrefixDelegate) {
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
    }
    
    deinit {
        print("OstAbortDeviceRecoveryWorkflowController :: I am deinit");
    }

    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentUser!.isStatusActivated {
            throw OstError("ui_i_wc_adwc_pudv_1", .userNotActivated);
        }
    }
    
    override func performUIActions() {
        DispatchQueue.main.async {
            self.getPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: self.getPinVCConfig())
            self.getPinViewController!.presentVCWithNavigation()
        }
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getAbortRecoveryPinVCConfig()
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .abortDeviceRecovery)
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstPinViewController ) {
            self.getPinViewController = nil;
            //The workflow has been cancled by user.
            self.postFlowInterrupted(error: OstError("ui_i_wc_auwc_vmfp_1", .userCanceled))
        }
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }

    override func onPassphrasePrefixSet(passphrase: String) {
        OstWalletSdk.abortDeviceRecovery(userId: self.userId,
                                         userPin: self.userPin!,
                                         passphrasePrefix: passphrase,
                                         delegate: self)
        showLoader(for: .abortDeviceRecovery)
    }
}
