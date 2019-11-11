/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit


extension OstWorkflowCallbacks {
    
    public func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.sdkPinAcceptDelegate = delegate;
        self.getPinViewController = nil
        openGetPinViewController()
    }
    
    @objc public func openGetPinViewController() {
        DispatchQueue.main.async {
            self.getPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: self.getPinVCConfig());
            
            self.showPinViewController()
        }
    }
    
    @objc func showPinViewController() {
      self.getPinViewController?.presentVCWithNavigation()
    }
    
    @objc func getPinVCConfig() -> OstPinVCConfig {
        fatalError("getPinVCConfig did not override in \(String(describing: self))")
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
    
    func cancelPinAcceptor() {
        self.sdkPinAcceptDelegate?.cancelFlow();
        self.sdkPinAcceptDelegate = nil;
    }
    
    @objc public func pinProvided(pin: String) {
        self.showLoader(for: getWorkflowType());
        self.passphrasePrefixDelegate?.getPassphrase(ostUserId: self.userId,
                                                     workflowContext: getWorkflowContext(),
                                                     delegate: self);
    }
    
    @objc func getWorkflowContext() -> OstWorkflowContext {
        fatalError("getWorkflowContext is not override in \(String(describing: self))")
    }
  
    @objc func getWorkflowType() -> OstWorkflowType {
         fatalError("getWorkflowType is not override in \(String(describing: self))")
     }
    
    @objc public func setPassphrase(ostUserId: String, passphrase: String) {
        self.sdkPinAcceptDelegate = nil;
        self.userPin = nil;
    }
    
    public func invalidPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.getPinViewController!.showInvalidPin(errorMessage: "Invalid entered pin, Retry again.");
        self.hideLoader();
        self.sdkPinAcceptDelegate = delegate;
    }
}
