/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstWorkflowCallbacks: NSObject, OstWorkflowDelegate, OWPassphrasePrefixAcceptDelegate, OstPinInputDelegate {
    
    /// Mark - Pin extension variables
    var userPin:String? = nil;
    var sdkPinAcceptDelegate: OstPinAcceptDelegate? = nil;
    var passphrasePrefixDelegate:OWPassphrasePrefixDelegate?;
    var getPinViewController:OstGetPinViewController? = nil;

    /// Mark - Workflow callback vars.
    let workflowId: String
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

    init(userId: String, passphrasePrefixDelegate:OWPassphrasePrefixDelegate) {
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
            delegate.deviceRegistered( apiResponse! );
        }) { (apiError) in
            if ( "ALREADY_EXISTS".caseInsensitiveCompare((apiError!["code"] as? String ?? "")) == .orderedSame ) {
                var device = apiParams;
                device["status"] = "REGISTERED";
                delegate.deviceRegistered( device );
            } else {
                delegate.cancelFlow();
            }
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
            
        }else if workflowContext.workflowType == .revokeDeviceWithQRCode {
            delegate.dataVerified()
            
        }else if workflowContext.workflowType == .executeTransaction {
             let entity: [String: Any] = ostContextEntity.entity as! [String: Any]
            
            let vc = OstVerifyTransactionViewController()
            vc.transferAmounts = entity["amounts"] as? [String]
            vc.tokenHolderAddress = entity["token_holder_addresses"] as? [String]
            vc.ruleName = entity["rule_name"] as? String
            vc.options = entity["options"] as? [String: Any]
            vc.delegate = delegate as OstBaseDelegate
            vc.showVC()
            
        }
    }
    
    func flowComplete(workflowContext: OstWorkflowContext,
                      ostContextEntity: OstContextEntity) {
        
        OstNotificationManager.getInstance.show(withWorkflowContext: workflowContext,
                                                contextEntity: ostContextEntity,
                                                error: nil)
        
        if workflowContext.workflowType == .executeTransaction {
            
            if let transaction: OstTransaction = ostContextEntity.entity as? OstTransaction,
                let transfers: [[String: Any]] = transaction.data["transfers"] as? [[String: Any]] {
                
                var tokenHolderAddresses: Set<String> = Set<String>()
                for transfer in transfers {
                    if let address = transfer["to"] as? String {
                        tokenHolderAddresses.insert(address)
                    }
                    
                    if let address = transfer["from"] as? String {
                        tokenHolderAddresses.insert(address)
                    }
                }
                
                var executeTransactionNotification: [String: Any] = [:]
                executeTransactionNotification["tokenHolderAddresses"] = Array(tokenHolderAddresses)
                executeTransactionNotification["isRequestAcknowledged"] = false
                
                NotificationCenter.default.post(name: NSNotification.Name("updateUserDataForTransaction"),
                                                object: executeTransactionNotification,
                                                userInfo: nil)
            }
        }
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        
        self.interact.broadcaseEvent(workflowId: self.workflowId, eventType: .flowComplete, eventHandler: eventData);

        let onComplete: ((Bool) -> Void) = {[weak self] (isComplete) in
            self?.hideLoader();
            self?.dismissPinViewController();
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
    
    func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
    
        OstNotificationManager.getInstance.show(withWorkflowContext: workflowContext,
                                                contextEntity: nil,
                                                error: error)
        
        var eventData = OstInteractEventData()
        eventData.workflowContext = workflowContext
        eventData.error = error
        
        let onComplete: ((Bool) -> Void) = {[weak self] (isComplete) in
            self?.hideLoader();
            self?.dismissPinViewController();
            self?.cleanUp();
        }
        
        if error.messageTextCode == .deviceNotSet {
            onComplete(true)
            BaseAPI.logoutUnauthorizedUser()
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
    
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
        if workflowContext.workflowType == .executeTransaction {
            if let tokenHolderAddress = CurrentUserModel.getInstance.ostUser?.tokenHolderAddress {
                
                var executeTransactionNotification: [String: Any] = [:]
                executeTransactionNotification["tokenHolderAddresses"] = [tokenHolderAddress]
                executeTransactionNotification["isRequestAcknowledged"] = true
                
                NotificationCenter.default.post(name: NSNotification.Name("updateUserDataForTransaction"),
                                                object: executeTransactionNotification,
                                                userInfo: nil)
            }
        }
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        eventData.workflowContext = workflowContext
        interact.broadcaseEvent(workflowId: self.workflowId, eventType: .requestAcknowledged, eventHandler: eventData)
        
        progressIndicator?.showAcknowledgementAlert(forWorkflowType: workflowContext.workflowType)
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func cancelFlow(error:[String:Any]?) {
        let errorMessage:String? = error?["display_message"] as? String;
        if ( nil != errorMessage ) {
            progressIndicator?.showFailureAlert(withTitle: errorMessage!, onCompletion: {[weak self] (_) in
                self?.cancelPinAcceptor();
            })
        }else {
            self.cancelPinAcceptor();
        }
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
