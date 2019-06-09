/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class OstSuccessNotification: OstNotification {
    
    class func showNotification(withMessage msg: String) {
        let notification = OstSuccessNotification()
        notification.message = msg
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            notification.show { (isCompleted) in
                if isCompleted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        notification.hide()
                    })
                }
            }
        })
    }
    
    override func getContainerBackgorundColor() -> UIColor {
        return UIColor.color(22, 141, 193)
    }
    
    override func getImage() -> UIImage? {
        return UIImage(named: "NotificationSuccessImage")
    }
    
    //MARK: - Notification Text
    
    override func getTitle() -> String {
        let workflowContext = notificationModel.workflowContext
        var titleText = ""
        
        if workflowContext.workflowType == .addSession {
            titleText = getAddSessionText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .resetPin {
            titleText = "Pin has been reset successfully."
        }
        else if workflowContext.workflowType == .activateUser {
            titleText = "Congratulations! Your wallet is now ready."
        }
        else if workflowContext.workflowType == .authorizeDeviceWithMnemonics {
            titleText = "Device authorized successfully."
        }
        else if workflowContext.workflowType == .authorizeDeviceWithQRCode {
            titleText = getAuthorizeDeviceWithQRText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .executeTransaction {
            titleText = "transaction executed successfully!"
        }
        
        return titleText
    }
    
    func getAddSessionText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        var titleText = "Session created successfully."
        if let entity: OstSession = contextEntity!.entity as? OstSession {
            let aproxExpirationTime = entity.approxExpirationTimestamp
            if aproxExpirationTime > 0 {
                let date = Date(timeIntervalSince1970:aproxExpirationTime)
                titleText += "It expires approximately on \(date.getDateString())"
            }
        }
        
        return titleText
    }
    
    func getAuthorizeDeviceWithQRText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        var titleText = "Device is authorized."
        if let device: OstDevice = contextEntity?.entity as? OstDevice {
            titleText = "Device with address \(device.address!) is now authroized. You can use device to do transactions or authrorize new device."
        }
        return titleText
    }
    
    //MAKR: - Action Button Title
    override func getActionButtonTitle() -> String {
        if notificationModel.workflowContext.workflowType == .executeTransaction {
            return "View Details"
        }
        return ""
    }
    
    //MAKR: - Actions
    
    @objc override func actionButtonTapped(_ sender: Any?) {
        if notificationModel.workflowContext.workflowType == .executeTransaction {
            showWebViewForTransaction()
        }
    }
    
    func showWebViewForTransaction() {
        let webView = WKWebViewController()
        let currentUser = CurrentUserModel.getInstance
        let currentEconomy = CurrentEconomy.getInstance
        
        let tokenHoderURL: String = "\(currentEconomy.viewEndPoint!)token/th-\(currentEconomy.auxiliaryChainId!)-\(currentEconomy.utilityBrandedToken!)-\(currentUser.tokenHolderAddress!)"
        webView.title = "OST View"
        webView.urlString = tokenHoderURL
        webView.showVC()
        OstNotificationManager.getInstance.removeNotification()
    }
}
