/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class OstErroNotification: OstNotification {
    
    override func getContainerBackgorundColor() -> UIColor {
        return UIColor.color(255, 132, 133)
    }
    
    override func getImage() -> UIImage? {
        return UIImage(named: "NotificationErrorImage")
    }
}
