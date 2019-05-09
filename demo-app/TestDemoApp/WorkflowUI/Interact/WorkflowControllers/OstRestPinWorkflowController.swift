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
    var setPinViewController: OstGetPinViewController? = nil;
    var newPinViewController: OstSetNewPinViewController? = nil;
    var confirmNewPinViewController: OstConfirmNewPinViewController? = nil;

    init(userId: String,
         passphrasePrefixDelegate:OstPassphrasePrefixDelegate,
         presenter:UIViewController) {
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
        self.setPinViewController = OstGetPinViewController.newInstance(pinInputDelegate: self);
        self.observeViewControllerIsMovingFromParent();
        
        if ( nil == presenter.navigationController ) {
            self.setPinViewController!.presentViewControllerWithNavigationController(presenter);
        } else {
            //Push into existing navigation controller.
            self.setPinViewController!.pushViewControllerOn( presenter.navigationController! );
        }
    }
    
    deinit {
        print("OstActivateUserWorkflowController :: I am deinit ");
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if ( notification.object is OstConfirmNewPinViewController ) {
            self.confirmNewPinViewController = nil;
        } else if ( notification.object is OstSetNewPinViewController ) {
            self.setPinViewController = nil;
        } else if ( notification.object is OstGetPinViewController ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .activateUser),
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
            self.newPinViewController!.showInvalidPin()
        }
        else if (nil == self.newPin || nil == self.confirmNewPinViewController) {
            self.newPin = pin
            showConfirmNewPinViewController()
        }
        else if (self.newPin!.caseInsensitiveCompare(pin) != .orderedSame) {
            self.confirmNewPinViewController!.showInvalidPin()
        }
        else {
            passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId, ostPassphrasePrefixAcceptDelegate: self);
        } 
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .activateUser),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            return;
        }
        
        OstWalletSdk.resetPin(userId: self.userId,
                              passphrasePrefix: passphrase,
                              oldUserPin: self.userPin!,
                              newUserPin: self.newPin!,
                              delegate: self)
        
        self.userPin = nil;
        showLoader();
    }
    
    
    func showGetNewPinViewController() {
        self.newPinViewController = OstSetNewPinViewController.newInstance(pinInputDelegate: self)
        self.newPinViewController?.pushViewControllerOn(self.setPinViewController!);
    }
    
    func showConfirmNewPinViewController() {
        self.confirmNewPinViewController = OstConfirmNewPinViewController.newInstance(pinInputDelegate: self)
        self.confirmNewPinViewController?.pushViewControllerOn(self.newPinViewController!);
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.setPinViewController ) {
            self.setPinViewController?.removeViewController();
        }
        self.setPinViewController = nil;
        self.confirmNewPinViewController = nil
        self.newPinViewController = nil
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }
    
    override func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        self.setPinViewController!.removeViewController()
    }
}
