/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstAbortDeviceRecoveryWorkflowController: OstBaseWorkflowController {
    
    /// Mark - View Controllers.
    
    override init(userId: String,
                  passphrasePrefixDelegate:OstPassphrasePrefixDelegate) {
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
    }
    
    deinit {
        print("OstAbortDeviceRecoveryWorkflowController :: I am deinit");
    }

    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if self.currentDevice!.isStatusRevoked {
            throw OstError("i_wc_adwc_pudv_1", .deviceNotSet);
        }
    }
    
    override func performUIActions() {
        DispatchQueue.main.async {
            self.getPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: OstPinVCConfig.getAbortRecoveryPinVCConfig());
            self.getPinViewController!.presentVCWithNavigation()
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .abortDeviceRecovery)
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstPinViewController ) {
            self.getPinViewController = nil;
            //The workflow has been cancled by user.
            
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .abortDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .abortDeviceRecovery),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        
        showLoader(progressText: .stopDeviceRecovery)
        OstWalletSdk.abortDeviceRecovery(userId: self.userId,
                                         userPin: self.userPin!,
                                         passphrasePrefix: passphrase,
                                         delegate: self)
        self.userPin = nil;
        
    }
    
    public override func cleanUpPinViewController() {
        self.sdkPinAcceptDelegate = nil;
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.getPinViewController ) {
            self.getPinViewController?.removeViewController();
        }
        self.getPinViewController = nil;
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }
    
    override func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        
        hideLoader()
        cleanUp()
    }
}
