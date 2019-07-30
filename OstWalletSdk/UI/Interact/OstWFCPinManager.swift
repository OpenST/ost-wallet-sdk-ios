/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

extension OstWorkflowCallbacks {
    
    func showGetPinViewController() {
        
        let win = getWindow()
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        observeViewControllerIsMovingFromParent()
        let navC = UINavigationController(rootViewController: self.getPinViewController!);
        vc.present(navC, animated: true, completion: nil)
    }
    
    @objc public func cleanUpPinViewController() {
        self.getPinViewController?.removeViewController()
        self.sdkPinAcceptDelegate = nil;
        self.getPinViewController = nil;
    }
    
    func getPinViewControllerDismissed() {
        self.getPinViewController = nil;
        self.cancelPinAcceptor();
    }
    
    @objc public func pinProvided(pin: String) {
        userPin = pin;
        self.showLoader(progressText: .unknown);
        self.passphrasePrefixDelegate?.getPassphrase(ostUserId: self.userId,
                                                     workflowContext: getWorkflowContext(),
                                                     delegate: self);
    }
    
    @objc func getWorkflowContext() -> OstWorkflowContext {
        fatalError("getWorkflowContext is not override.")
    }
    
    func cancelPinAcceptor() {
        self.sdkPinAcceptDelegate?.cancelFlow();
        self.sdkPinAcceptDelegate = nil;
    }
    
    @objc public func setPassphrase(ostUserId: String, passphrase: String) {
        self.sdkPinAcceptDelegate?.pinEntered(self.userPin!, passphrasePrefix: passphrase);
        self.sdkPinAcceptDelegate = nil;
        self.userPin = nil;
        self.showLoader(progressText: .unknown);
    }
    
    public func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.sdkPinAcceptDelegate = delegate;
        self.getPinViewController = OstPinViewController
            .newInstance(pinInputDelegate: self,
                         pinVCConfig: OstPinVCConfig.getConfirmPinVCConfig());
        showGetPinViewController();
    }
    
    public func invalidPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.getPinViewController!.showInvalidPin(errorMessage: "Invalid entered pin, Retry again.");
        self.hideLoader();
        self.sdkPinAcceptDelegate = delegate;
    }
}
