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
    
    class func showNotification(withMessage msg: String) {
        let notification = OstErroNotification()
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
        return UIColor.color(255, 132, 133)
    }
    
    override func getImage() -> UIImage? {
        return UIImage(named: "NotificationErrorImage")
    }
    
    //MARK: - Notification Text
    override func getTitle() -> String {
        return notificationModel.error?.errorMessage ?? ""
    }
}
