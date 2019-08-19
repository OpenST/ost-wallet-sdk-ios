/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstAbortDeviceRecoveryWorkflowController: OstWorkflowCallbacks {
    
    /// Mark - View Controllers.
    
    init(userId: String,
         passphrasePrefixDelegate:OWPassphrasePrefixDelegate,
         presenter: UIViewController) {
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
        self.getPinViewController = OstGetPinViewController.newInstance(pinInputDelegate: self);
        self.observeViewControllerIsMovingFromParent();
        
        if ( nil == presenter.navigationController ) {
            self.getPinViewController!.presentViewControllerWithNavigationController(presenter);
        } else {
            //Push into existing navigation controller.
            self.getPinViewController!.pushViewControllerOn( presenter.navigationController! );
        }
    }
    
    deinit {
        print("OstActivateUserWorkflowController :: I am deinit ");
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstGetPinViewController ) {
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
        
        OstWalletSdk.abortDeviceRecovery(userId: self.userId,
                                         userPin: self.userPin!,
                                         passphrasePrefix: passphrase,
                                         delegate: self)
        self.userPin = nil;
        showLoader(progressText: .stopDeviceRecovery);
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        self.userPin = pin;
        showLoader(progressText: .stopDeviceRecovery);
        passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId, ostPassphrasePrefixAcceptDelegate: self);
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
}
