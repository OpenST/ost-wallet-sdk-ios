/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstWorkflowCallbacks: OstWorkflowDelegate {
    private static var workflowIdentifierCounter: Double = 0
    
    let workflowId: String
    
    private var interact: OstSdkInteract {
        return OstSdkInteract.getInstance
    }
    
    init() {
        self.workflowId = String(OstWorkflowCallbacks.workflowIdentifierCounter)
        OstWorkflowCallbacks.workflowIdentifierCounter += 1
    }
    
    func registerDevice(_ apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        
        let currentUser = CurrentUser.getInstance()
        
        //Make API call to Mappy App Server.
        let resourceUrl = "/users/" + currentUser.appUserId! + "/devices";
        currentUser.post(resource: resourceUrl,
                         params: apiParams as [String : AnyObject],
                         onSuccess: { (appApiResponse:[String : Any]?) in
                    
                    try! delegate.deviceRegistered( appApiResponse! );
        }) { (failureResponse) in
            delegate.cancelFlow();
        }
    }
    
    func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        getPinFromUser(ostPinAcceptProtocol: delegate)
    }
    
    func invalidPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        getPinFromUser(message: "Invalid pin, Please re-enter", ostPinAcceptProtocol: delegate)
    }
    
    func pinValidated(_ userId: String) {
       
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
        
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowComplete, eventHandler: eventData)
    }
    
    func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        var eventData = OstInteractEventData()
        eventData.workflowContext = workflowContext
        eventData.error = error
        
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowInterrupted, eventHandler: eventData)
    }
    
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        
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
    
}

public extension UIAlertController {
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
