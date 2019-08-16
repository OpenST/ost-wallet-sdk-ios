/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstResetPinWorkflowController: OstBaseWorkflowController {
    
    var newPin: String? = nil
    
    var setNewPinViewController: OstPinViewController? = nil
    var confirmNewPinViewController: OstPinViewController? = nil
    
    override func performUIActions() {
        openGetPinViewController()
    }
    
    //MAKR: - Open View Controller
    func openGetPinViewController() {
        DispatchQueue.main.async {
            if nil == self.getPinViewController {
                self.getPinViewController = OstPinViewController
                    .newInstance(pinInputDelegate: self,
                                 pinVCConfig: OstContent.getPinForResetPinVCConfig())
            }
            
            self.getPinViewController!.presentVCWithNavigation()
        }
    }
    
    func openSetNewPinViewController() {
        DispatchQueue.main.async {
            if nil == self.setNewPinViewController {
                self.setNewPinViewController = OstPinViewController
                    .newInstance(pinInputDelegate: self,
                                 pinVCConfig: OstContent.getSetNewPinForResetPinVCConfig())
            }
            self.setNewPinViewController!.pushViewControllerOn(self.getPinViewController!)
        }
    }
    
    func openConfirmNewPinViewController() {
        DispatchQueue.main.async {
            if nil == self.confirmNewPinViewController {
                self.confirmNewPinViewController = OstPinViewController
                    .newInstance(pinInputDelegate: self,
                                 pinVCConfig: OstContent.getConfirmNewPinForResetPinVCConfig())
            }
            self.confirmNewPinViewController!.pushViewControllerOn(self.setNewPinViewController!)
        }
    }
    
    @objc override func vcIsMovingFromParent(_ notification: Notification) {
        
        if ( notification.object is OstPinViewController ) {
            
            if nil != self.confirmNewPinViewController {
                self.confirmNewPinViewController = nil
                
            }else if nil != self.setNewPinViewController {
                self.setNewPinViewController = nil
                
            } else {
                self.postFlowInterrupted(error: OstError("ui_i_wc_rpwc_vmfp_1", .userCanceled))
                cleanUp()
            }
        }else {
            self.getPinViewController?.removeViewController(flowEnded: true)
            cleanUp()
        }
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        
        if ( nil == self.userPin || nil == self.setNewPinViewController ) {
            self.userPin = pin;
            openSetNewPinViewController()
            
        }else if (self.userPin!.caseInsensitiveCompare(pin) == .orderedSame && nil == self.newPin){
            self.setNewPinViewController!.showInvalidPin(errorMessage: "Previous pin and new pin should not be same.")
            
        }else if (nil == self.newPin || nil == self.confirmNewPinViewController) {
            self.newPin = pin
            openConfirmNewPinViewController()
            
        } else if (self.newPin!.caseInsensitiveCompare(pin) != .orderedSame) {
            self.confirmNewPinViewController!.showInvalidPin(errorMessage: "Please enter same pin as new pin.")

        }else {
            super.pinProvided(pin: pin)
        }
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        
        OstWalletSdk.resetPin(userId: self.userId,
                              passphrasePrefix: passphrase,
                              oldUserPin: self.userPin!,
                              newUserPin: self.newPin!,
                              delegate: self)
        showLoader(progressText: .resetPin);
    }
    
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .resetPin)
    }
    
    override func cleanUp() {
        super.cleanUp();
        self.setNewPinViewController = nil;
        self.confirmNewPinViewController = nil;
    }
}
