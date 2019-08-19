/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class OstRestPinWorkflowController: OstWorkflowCallbacks {

    //MARK: - Variables
    var newPin: String? = nil
    
    /// Mark - View Controllers.
    var newPinViewController: OstSetNewPinViewController? = nil;
    var confirmNewPinViewController: OstConfirmNewPinViewController? = nil;

    init(userId: String,
         passphrasePrefixDelegate:OWPassphrasePrefixDelegate,
         presenter:UIViewController) {
        
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
            
        if ( notification.object is OstConfirmNewPinViewController ) {
            self.confirmNewPinViewController = nil;
        } else if ( notification.object is OstSetNewPinViewController ) {
            self.newPin = nil
            self.newPinViewController = nil;
        } else if ( notification.object is OstGetPinViewController ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .resetPin),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
            cleanUp()
        }
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        
        if (nil == self.userPin ||  nil == self.newPinViewController) {
            self.userPin = pin
            showGetNewPinViewController()
        }
        else if (self.userPin!.caseInsensitiveCompare(pin) == .orderedSame && nil == self.newPin) {
            self.newPinViewController!.showInvalidPin(errorMessage: "Previous pin and new pin should not be same.")
        }
        else if (nil == self.newPin || nil == self.confirmNewPinViewController) {
            self.newPin = pin
            showConfirmNewPinViewController()
        }
        else if (self.newPin!.caseInsensitiveCompare(pin) != .orderedSame) {
            self.confirmNewPinViewController!.showInvalidPin(errorMessage: "Please enter same pin as new pin.")
        }
        else {
            showLoader(progressText: .resetPin);
            passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId, ostPassphrasePrefixAcceptDelegate: self);
        } 
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .resetPin),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        
        OstWalletSdk.resetPin(userId: self.userId,
                              passphrasePrefix: passphrase,
                              oldUserPin: self.userPin!,
                              newUserPin: self.newPin!,
                              delegate: self)
        
        self.userPin = nil;
        showLoader(progressText: .resetPin);
    }
    
    
    func showGetNewPinViewController() {
        self.newPinViewController = OstSetNewPinViewController.newInstance(pinInputDelegate: self)
        self.newPinViewController?.pushViewControllerOn(self.getPinViewController!);
    }
    
    func showConfirmNewPinViewController() {
        self.confirmNewPinViewController = OstConfirmNewPinViewController.newInstance(pinInputDelegate: self)
        self.confirmNewPinViewController?.pushViewControllerOn(self.newPinViewController!);
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.getPinViewController ) {
            self.getPinViewController?.removeViewController();
        }
        self.getPinViewController = nil;
        self.confirmNewPinViewController = nil
        self.newPinViewController = nil
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }

}
