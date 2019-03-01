//
//  OstTokenHolderDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderDbQueries: OstBaseDbQueries {
    /// Get activity name for OstTokenHolder
    ///
    /// - Returns: Activity name
    override func activityName() -> String{
        return "token_holders"
    }
}
