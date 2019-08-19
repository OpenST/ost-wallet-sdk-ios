/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class OstLogoutAllSessionWorkflowController: OstWorkflowCallbacks {
   
    init(userId: String,
         passphrasePrefixDelegate: OWPassphrasePrefixDelegate,
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
        print("OstLogoutAllSessionWorkflowController :: I am deinit ");
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstSetNewPinViewController ) {
            self.getPinViewController = nil;
            //The workflow has been cancled by user.
            
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .logoutAllSessions),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .logoutAllSessions),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        
        OstWalletSdk.logoutAllSessions(userId: self.userId, delegate: self)
        
        self.userPin = nil;
        showLoader(progressText: OstProgressIndicatorTextCode.logoutUser);
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        self.userPin = pin;
        passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId, ostPassphrasePrefixAcceptDelegate: self);
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
