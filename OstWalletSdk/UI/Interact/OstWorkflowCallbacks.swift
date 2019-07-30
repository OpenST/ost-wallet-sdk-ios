/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

@objc public class OstWorkflow: NSObject {
    private weak var workflowCallbacks: OstWorkflowCallbacks?

    @objc
    public var workflowId: String? {
        return workflowCallbacks?.workflowId
    }
    
    init(workflowCallbacks: OstWorkflowCallbacks) {
        self.workflowCallbacks = workflowCallbacks
    }
    
    @objc
    public func subscribe(workflowDelegate: OstWorkflowUIDelegate) {
        if let workflowIdStr = self.workflowId {
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowIdStr,
                                                listner: workflowDelegate)
        }
    }
    
    @objc 
    public func unsubscribe(workflowDelegate: OstWorkflowUIDelegate) {
        if let workflowIdStr = self.workflowId {
            OstSdkInteract.getInstance.unsubscribe(forWorkflowId: workflowIdStr,
                                                   listner: workflowDelegate)
        }
    }
}

@objc public class OstWorkflowCallbacks: NSObject, OstWorkflowDelegate, OstPassphrasePrefixAcceptDelegate, OstPinInputDelegate {
    
    /// Mark - Pin extension variables
    var userPin:String? = nil;
    var sdkPinAcceptDelegate:OstPinAcceptDelegate? = nil;
    var passphrasePrefixDelegate: OstPassphrasePrefixDelegate?
    var getPinViewController: OstPinViewController? = nil

    /// Mark - Workflow callback vars.
    public let workflowId: String
    let userId: String
    
    var uiWindow: UIWindow? = nil
    
    func getWindow() -> UIWindow {
        if nil == uiWindow {
            let win = UIWindow(frame: UIScreen.main.bounds)
            win.windowLevel = UIWindow.Level.alert + 1
            win.makeKeyAndVisible()
            uiWindow = win
            return win
        }
        
        return uiWindow!
    }
    
    var progressIndicator: OstProgressIndicator? = nil
    
    private var interact: OstSdkInteract {
        return OstSdkInteract.getInstance
    }

    init(userId: String,
         passphrasePrefixDelegate:OstPassphrasePrefixDelegate) {
        
        self.userId = userId;
        self.workflowId = UUID().uuidString;
        self.passphrasePrefixDelegate = passphrasePrefixDelegate;
    }
    
    deinit {
        print("OstWorkflowCallbacks :: I am deinit for \(self.workflowId)")
    }
    
    func observeViewControllerIsMovingFromParent() {
        //self.setPinViewController
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(vcIsMovingFromParent(_:)),
                                               name: .ostVCIsMovingFromParent,
                                               object: nil)
    }

    @objc func vcIsMovingFromParent(_ notification: Notification) {
        if ( nil != notification.object && notification.object! as? OstBaseViewController === self.getPinViewController ) {
            self.getPinViewControllerDismissed();
        }
    }
        
    @objc public func registerDevice(_ apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        // To-Do: Ensure its setupDevice workflow.
        // else do not do it. Logout the user.
    }

    @objc public func verifyData(workflowContext: OstWorkflowContext,
                                 ostContextEntity: OstContextEntity,
                                 delegate: OstValidateDataDelegate) {
        
    }
    
    @objc public func flowComplete(workflowContext: OstWorkflowContext,
                      ostContextEntity: OstContextEntity) {
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        
        self.interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowComplete, eventHandler: eventData);

        let onComplete: ((Bool) -> Void) = {[weak self] (isComplete) in
            self?.hideLoader();
            self?.cleanUpPinViewController();
            self?.cleanUp();
        }
        
        if nil != progressIndicator
            && workflowContext.workflowType != .getDeviceMnemonics {
            
            progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                                onCompletion: onComplete)
            return
        }
        
        onComplete(true)
    }
    
    @objc public func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
    
        var eventData = OstInteractEventData()
        eventData.workflowContext = workflowContext
        eventData.error = error
        
        let onComplete: ((Bool) -> Void) = {[weak self] (isComplete) in
            self?.hideLoader();
            self?.cleanUpPinViewController();
            self?.cleanUp();
        }
        
        if error.messageTextCode == .deviceNotSet {
            onComplete(true)
            return
        }
        
        self.interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowInterrupted, eventHandler: eventData);
        
        if nil != progressIndicator && error.messageTextCode != .userCanceled {
            progressIndicator?.showFailureAlert(forWorkflowType: workflowContext.workflowType,
                                                error: error,
                                                onCompletion: onComplete)
            return
        }
        onComplete(true)
    }
    
    @objc public func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .requestAcknowledged, eventHandler: eventData)
        
        progressIndicator?.showAcknowledgementAlert(forWorkflowType: workflowContext.workflowType)
        
    }
    
    @objc public func pinValidated(_ userId: String) {
        
    }
    
    public func cancelFlow() {
        progressIndicator?.showFailureAlert(withTitle: "Cancelled", onCompletion: {[weak self] (_) in
            self?.cancelPinAcceptor();
        })
    }
    
    func cleanUp() {
        progressIndicator?.hide()
        self.cleanUpPinViewController();
        progressIndicator = nil
        uiWindow = nil
    }
    
    func showLoader(progressText: OstProgressIndicatorTextCode) {
        if ( nil != progressIndicator ) {
            if ( nil != progressIndicator!.alert ) {
                //progressIndicator is showing.
                progressIndicator?.textCode = progressText
                return;
            }
        }
        progressIndicator = OstProgressIndicator(textCode: progressText)
        progressIndicator?.show()
    }
    
    func hideLoader() {
        progressIndicator?.hide()
        progressIndicator = nil
        uiWindow = nil
    }
}
