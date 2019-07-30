/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

@objc public class OstWalletSdkUI: NSObject {
    

    /// Set theme config for OstWalletUI
    ///
    /// - Parameter config: Theme config
    @objc
    public class func setThemeConfig(_ config: [String: Any]) {
        _ = OstTheme(themeConfig: config)
    }
    
    @objc
    /// Set content config for OstWalletUI
    ///
    /// - Parameter config: Content config
    public class func setContentConfig(_ config: [String: Any]) {
        _ = OstContent(contentConfig: config)
    }
    
    /// Once device setup is completed, call active user to deploy token holder.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier
    ///   - expireAfterInSec: Session expiration time in seconds
    ///   - spendingLimit: Max amount that user can spend per transaction
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    /// - Returns: Workflow id
    @objc
    public class func activateUser(
        userId: String,
        expireAfterInSec: TimeInterval,
        spendingLimit: String,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstActivateUserWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            spendingLimit: spendingLimit,
            expireAfterInSec: expireAfterInSec)
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        workflowController.perform()
        return workflowController.workflowId
    }
    
    /// Initiate device recovery.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier
    ///   - recoverDeviceAddress: Device address of device tobe recovered.
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    public class func initaiteDeviceRecovery(
        userId: String,
        recoverDeviceAddress: String? = nil,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstInitiateDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate,
            recoverDeviceAddress: recoverDeviceAddress)
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        workflowController.perform()
        return workflowController.workflowId
    }
    
    /// Abort device recovery.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    public class func abortDeviceRecovery(
        userId: String,
        passphrasePrefixDelegate: OstPassphrasePrefixDelegate
        ) -> String {
        
        let workflowController = OstAbortDeviceRecoveryWorkflowController(
            userId: userId,
            passphrasePrefixDelegate: passphrasePrefixDelegate
        )
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: workflowController)
        workflowController.perform()
        return workflowController.workflowId
    }
    
    
    /// Subscribe to receive workflow events.
    ///
    /// - Parameters:
    ///   - workflowId: Workflow id
    ///   - listner: OstWorkflowUIDelegate
    @objc
    public class func subscribe(workflowId: String,
                                listner: OstWorkflowUIDelegate) {
        
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowId,
                                             listner: listner)
    }
    
    /// Unsubscribe to receive workflow events.
    ///
    /// - Parameters:
    ///   - workflowId:  Workflow id
    ///   - listner: OstWorkflowUIDelegate
    @objc
    public class func unsubscribe(workflowId: String,
                                  listner: OstWorkflowUIDelegate) {
        
        OstSdkInteract.getInstance.unsubscribe(forWorkflowId: workflowId,
                                               listner: listner)
    }
}
