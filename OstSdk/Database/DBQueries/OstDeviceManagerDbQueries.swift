//
//  OstDeviceManagerDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDeviceManagerDbQueries: OstBaseDbQueries {
    /// Get activity name for OstDeviceManager
    ///
    /// - Returns: Activity name
    override func activityName() -> String{
        return "device_managers"
    }
}
