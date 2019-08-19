/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation
import UIKit

@objc class OstActivateUserWorkflowController: OstBaseWorkflowController {

    let spendingLimit: String
    let expireAfterInSec:TimeInterval
    
    /// Mark - View Controllers.
    var createPinViewController: OstPinViewController? = nil
    var confirmPinViewController: OstPinViewController?;
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - expireAfterInSec: Relative time
    ///   - spendingLimit: Spending limit for transaction
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    init(userId: String,
         expireAfterInSec: TimeInterval,
         spendingLimit: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
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
        if !self.currentUser!.isStatusCreated {
            throw OstError("ui_i_wc_auwc_pudv_1", .userAlreadyActivated)
        }
        
        if !self.currentDevice!.isStatusRegistered {
            throw OstError("ui_i_wc_auwc_pudv_2", .deviceNotRegistered);
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .activateUser)
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        if (nil != self.confirmPinViewController && notification.object is OstPinViewController ) {
            self.confirmPinViewController = nil;
        } else if ( notification.object is OstPinViewController ) {
            self.createPinViewController = nil;
            //The workflow has been cancled by user.
            self.postFlowInterrupted(error: OstError("ui_i_wc_auwc_vmfp_1", .userCanceled))
        }
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        OstWalletSdk.activateUser(userId: self.userId,
                                  userPin: self.userPin!,
                                  passphrasePrefix: passphrase,
                                  spendingLimit: self.spendingLimit,
                                  expireAfterInSec: self.expireAfterInSec,
                                  delegate: self);
        
        showLoader(progressText: OstContent.getLoaderText(for: .activateUser));
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
                             pinVCConfig: OstContent.getCreatePinVCConfig())
            
            self.createPinViewController!.presentVCWithNavigation()
        }
    }

    func showConfirmPinViewController() {
        DispatchQueue.main.async {
           self.confirmPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: OstContent.getConfirmPinVCConfig())
            
            self.confirmPinViewController?.pushViewControllerOn(self.createPinViewController!);
        }
    }
    
    override func cleanUp() {
        if ( nil != self.createPinViewController ) {
           self.createPinViewController?.removeViewController(flowEnded: true)
        }
        self.createPinViewController = nil;
        self.confirmPinViewController = nil;
        super.cleanUp();
    }
}
