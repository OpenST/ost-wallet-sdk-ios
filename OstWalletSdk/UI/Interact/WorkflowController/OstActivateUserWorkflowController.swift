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

class OstActivateUserWorkflowController: OstBaseWorkflowController {

    let spendingLimit: String
    let expireAfterInSec:TimeInterval
    
    /// Mark - View Controllers.
    var createPinViewController: OstPinViewController? = nil
    var confirmPinViewController: OstPinViewController?;
    
    init(userId: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate,
         spendingLimit: String = OstUtils.toAtto("15"),
         expireAfterInSec: TimeInterval = TimeInterval(Double(14*24*60*60))
    ) {
        self.spendingLimit = spendingLimit
        self.expireAfterInSec = expireAfterInSec
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate)
    }
    
    deinit {
        print("OstActivateUserWorkflowController :: I am deinit ");
    }
    
    override func performUIActions() {
        self.showCreatePinViewController()
    }
    
    override func performUserDeviceValidation() throws {
        if self.currentUser!.isStatusActivated {
            throw OstError("i_wc_auwc_pudv_1", .userAlreadyActivated)
        }
        
        if (!self.currentDevice!.isStatusRegistered
            && (self.currentDevice!.isStatusRevoking
                || self.currentDevice!.isStatusRevoked)) {
            
            throw OstError("i_wc_auwc_pudv_2", .deviceNotSet);
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .activateUser)
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if (nil != self.confirmPinViewController && notification.object is OstPinViewController ) {
            self.confirmPinViewController = nil;
        } else if ( notification.object is OstPinViewController ) {
            self.createPinViewController = nil;
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
            super.pinProvided(pin: pin)
        } else {
            //Show error.
            self.confirmPinViewController?.showInvalidPin(errorMessage: "Please enter same pin as earlier.");
        }
    }
    
    func showCreatePinViewController() {
        DispatchQueue.main.async {
            self.createPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: OstPinVCConfig.getCreatePinVCConfig())
            
            self.createPinViewController!.presentVCWithNavigation()
        }
    }
    func showConfirmPinViewController() {
        DispatchQueue.main.async {
            self.confirmPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: OstPinVCConfig.getConfirmPinVCConfig());
            
            self.confirmPinViewController?.pushViewControllerOn(self.createPinViewController!);
        }
    }
    
    override func cleanUp() {
        super.cleanUp();
        if ( nil != self.createPinViewController ) {
           self.createPinViewController?.removeViewController(flowEnded: true)
        }
        self.createPinViewController = nil;
        self.confirmPinViewController = nil;
        self.passphrasePrefixDelegate = nil;
        self.progressIndicator = nil
        NotificationCenter.default.removeObserver(self);
    }
    
    override func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        
        hideLoader()
        cleanUp()
    }
}
