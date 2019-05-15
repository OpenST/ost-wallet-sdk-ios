/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class OstErroNotification: OstNotification {
    
    override func getContainerBackgorundColor() -> UIColor {
        return UIColor.color(255, 132, 133)
    }
    
    override func getImage() -> UIImage? {
        return UIImage(named: "NotificationErrorImage")
    }
    
    //MARK: - Notification Text
    
    override func getActivateUserText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
    
    override func getAddSessionText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
    
    override func getResetPinText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
    
    override func getAbortDeviceRecoveryText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
    
    override func getAuthorizeDeviceWithMnemonicsText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
    
    override func getAuthorizeDeviceWithQRText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
   
    override func getExecuteTransactionText (contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return error?.errorMessage ?? ""
    }
}
