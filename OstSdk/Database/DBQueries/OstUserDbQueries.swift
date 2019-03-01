//
//  UserDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstUserDbQueries: OstBaseDbQueries {
    /// Get activity name for OstUser
    ///
    /// - Returns: Activity name
    override func activityName() -> String{
        return "users"
    }
}
