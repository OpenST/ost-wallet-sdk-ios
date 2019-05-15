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
    
    override func getContainerBackgorundColor() -> UIColor {
        return UIColor.color(185, 209, 143)
    }
    
    override func getImage() -> UIImage? {
        return UIImage(named: "NotificationSuccessImage")
    }
    
    //MARK: - Notification Text
    
    override func getActivateUserText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return "User activated Successfully."
    }
    
    override func getAddSessionText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
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
    
    override func getResetPinText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return "Pin has been reset successfully."
    }
    
    override func getAbortDeviceRecoveryText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    override func getAuthorizeDeviceWithMnemonicsText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    override func getAuthorizeDeviceWithQRText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        var titleText = "Device is authorized."
        if let device: OstDevice = contextEntity?.entity as? OstDevice {
            titleText = "Device with address \(device.address!) is now authroized. You can use device to do transactions or authrorize new device."
        }
        return titleText
    }
    
    override func getExecuteTransactionText (contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return "\(CurrentEconomy.getInstance.tokenId) sent successfully!"
    }
    
    //MAKR: - Action Button Title
    override func getActionButtonTitle() -> String {
        if notificationModel.workflowContext.workflowType == .executeTransaction {
            return "View Transaction"
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
        webView.urlString = tokenHoderURL
        webView.showVC()
        OstNotificationManager.getInstance.removeNotification()
    }
}
