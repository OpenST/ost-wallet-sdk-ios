//
//  OstDeviceDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDeviceDbQueries: OstBaseDbQueries {
    /// Get activity name for OstDevices
    ///
    /// - Returns: Activity name
    override func activityName() -> String{
        return "devices"
    }
}
