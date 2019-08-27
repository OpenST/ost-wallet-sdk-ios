/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation
import UIKit
import OstWalletSdk;

class OstActivateUserWorkflowController: OstWorkflowCallbacks {

    let spendingLimit: String;
    let expireAfterInSec:TimeInterval;
    
    /// Mark - View Controllers.
    var setPinViewController:OstGetPinViewController? = nil;
    var confirmPinViewController:OstConfirmNewPinViewController?;
    
    init(userId: String,
         passphrasePrefixDelegate:OWPassphrasePrefixDelegate,
         presenter:UIViewController,
         spendingLimit: String = OstUtils.toAtto("15"),
         expireAfterInSec: TimeInterval = TimeInterval(Double(14*24*60*60))
    ) {
        self.spendingLimit = spendingLimit;
        self.expireAfterInSec = expireAfterInSec;
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
            self.confirmPinViewController = nil;
        } else if ( notification.object is OstSetNewPinViewController ) {
            self.setPinViewController = nil;
            //The workflow has been cancled by user.
            
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .activateUser),
                                 error: OstError("wui_i_wfc_auwc_vmfp_1", .userCanceled)
            );
        }
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .activateUser),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            /// TODO: (Future) Do Something here. May be cancel workflow?
            return;
        }
        
        CurrentUserModel.shouldPerfromActivateUserAfterDelay = true
        OstWalletSdk.activateUser(userId: self.userId,
                                  userPin: self.userPin!,
                                  passphrasePrefix: passphrase,
                                  spendingLimit: self.spendingLimit,
                                  expireAfterInSec: self.expireAfterInSec,
                                  delegate: self);
        self.userPin = nil;
        showLoader(progressText: .activingUser);
    }
    

    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        if ( nil == self.userPin || nil == self.confirmPinViewController ) {
            self.userPin = pin;
            showConfirmPinViewController();
        } else if ( self.userPin!.compare(pin) == .orderedSame ){
            //Fetch salt and inititate workflow.
            showLoader(progressText: .activingUser);
            passphrasePrefixDelegate!.getPassphrase(ostUserId: self.userId, ostPassphrasePrefixAcceptDelegate: self);
        } else {
            //Show error.
            self.confirmPinViewController?.showInvalidPin(errorMessage: "Please enter same pin as earlier.");
        }
    }
    
    func showConfirmPinViewController() {
        self.confirmPinViewController = OstConfirmNewPinViewController.newInstance(pinInputDelegate: self);
        self.confirmPinViewController?.pushViewControllerOn(self.setPinViewController!);
    }
    
    override func dismissPinViewController() {
        setPinViewController?.removeViewController()
        setPinViewController = nil
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.setPinViewController ) {
            self.setPinViewController?.removeViewController();
        }
        self.setPinViewController = nil;
        self.confirmPinViewController = nil;
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }
    
    override func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
        if workflowContext.workflowType == .activateUser  {
            let user: OstUser = ostContextEntity.entity as! OstUser
            if user.isStatusActivated {
                UserAPI.notifyUserActivated()
            }
            
            if  CurrentUserModel.shouldPerfromActivateUserAfterDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + CurrentUserModel.artificalDelayForActivateUser) {[weak self] in
                    self?.performFlowComplete(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
                }
                return
            }
        }
        
        super.flowComplete(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
    }
    
    override func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        
        hideLoader()
        cleanUp()
    }
    
    func performFlowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        CurrentUserModel.shouldPerfromActivateUserAfterDelay = false
        super.flowComplete(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        NotificationCenter.default.post(name: NSNotification.Name("userActivated"), object: nil)
    }

}
