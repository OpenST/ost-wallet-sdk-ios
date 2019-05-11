/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstWorkflowCallbacks: NSObject, OstWorkflowDelegate, OstPassphrasePrefixAcceptDelegate, OstPinInputDelegate {
    
    /// Mark - Pin extension variables
    var userPin:String? = nil;
    var sdkPinAcceptDelegate:OstPinAcceptDelegate? = nil;
    var passphrasePrefixDelegate:OstPassphrasePrefixDelegate?;
    var getPinViewController:OstGetPinViewController? = nil;

    /// Mark - Workflow callback vars.
    let workflowId: String
    let userId: String
    
    var uiWindow: UIWindow? = nil
    
    func getWindow() -> UIWindow{
        if nil == uiWindow {
            let win = UIWindow(frame: UIScreen.main.bounds)
            win.windowLevel = UIWindow.Level.alert + 1
            win.makeKeyAndVisible()
            uiWindow = win
        }
        
        return uiWindow!
    }
    
    var progressIndicator: OstProgressIndicator? = nil
    
    private var interact: OstSdkInteract {
        return OstSdkInteract.getInstance
    }

    init(userId: String, passphrasePrefixDelegate:OstPassphrasePrefixDelegate) {
        self.userId = userId;
        self.workflowId = UUID().uuidString;
        self.passphrasePrefixDelegate = passphrasePrefixDelegate;
    }
    
    func observeViewControllerIsMovingFromParent() {
        //self.setPinViewController
        NotificationCenter.default.addObserver(self, selector: #selector(vcIsMovingFromParent(_:)), name: .ostVCIsMovingFromParent, object: nil)
    }

    @objc func vcIsMovingFromParent(_ notification: Notification) {
        if ( nil != notification.object && notification.object! as? OstBaseViewController === self.getPinViewController ) {
            self.getPinViewControllerDismissed();
        }
    }
        
    func registerDevice(_ apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        // To-Do: Ensure its setupDevice workflow.
        // else do not do it. Logout the user.

        DeviceAPI.registerDevice(params: apiParams, onSuccess: { (apiResponse) in
            try! delegate.deviceRegistered( apiResponse! );
        }) { (apiError) in
            delegate.cancelFlow();
        }
    }
    
        
    func verifyData(workflowContext: OstWorkflowContext,
                    ostContextEntity: OstContextEntity,
                    delegate: OstValidateDataDelegate) {
        if workflowContext.workflowType == .authorizeDeviceWithQRCode {
            let vc = OstVerifyAuthDeviceViewController()
            vc.workflowContext = workflowContext
            vc.contextEntity = ostContextEntity
            vc.delegate = delegate as OstBaseDelegate
            vc.showVC()
        }
    }
    
    func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        hideLoader();
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowComplete, eventHandler: eventData);
        cleanUp();
    }
    
    func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        var eventData = OstInteractEventData()
        eventData.workflowContext = workflowContext
        eventData.error = error
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowInterrupted, eventHandler: eventData);
        hideLoader();
        cleanUp();
    }
    
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        hideLoader();
        dismissPinViewController();
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .requestAcknowledged, eventHandler: eventData)
    }
    
    func getPinFromUser(title: String = "Enter your pin",
                        message: String = "",
                        ostPinAcceptProtocol: OstPinAcceptDelegate) {
        
        let currentUser = CurrentUser.getInstance();
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        //Add a text field.
        alert.addTextField { (textField) in
            textField.placeholder = "6 digit pin"
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = true
            textField.textAlignment = .center;
        }
        //Add action
        let action = UIAlertAction(title: "Validate", style: .default) { (alertAction) in
            let pinTextField = alert.textFields![0] as UITextField
            if ((pinTextField.text?.count)! < 6 ) {
                self.getPinFromUser( message: "Invalid Pin",ostPinAcceptProtocol: ostPinAcceptProtocol)
                return;
            }
            ostPinAcceptProtocol.pinEntered(pinTextField.text!, passphrasePrefix: currentUser.userPinSalt!);
            alert.dismiss(animated: true, completion: nil);
        }
        alert.addAction(action);
        alert.show()
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func cancelFlow() {
        self.cancelPinAcceptor();
    }
    
    func cleanUp() {
        progressIndicator?.hide()
        self.cleanUpPinViewController();
        progressIndicator = nil
        uiWindow = nil
    }
    
    func showLoader(progressText: String) {
        progressIndicator = OstProgressIndicator(progressText: progressText)
        let window = getWindow()
        window.addSubview(progressIndicator!)
        progressIndicator?.show()
    }
    
    func hideLoader() {
        progressIndicator?.hide()
    }
}

public extension UIAlertController {
    @available(*, deprecated, message: "Please avoid using this method.")
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}

public extension UIViewController {
    @available(*, deprecated, message: "Please avoid using this method.")
    func showVC() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        let navC = UINavigationController(rootViewController: self)
        vc.present(navC, animated: true, completion: nil)
    }
}
