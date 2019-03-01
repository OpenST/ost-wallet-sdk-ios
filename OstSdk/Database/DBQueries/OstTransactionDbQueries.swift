//
//  OstTransactionDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTransactionDbQueries: OstBaseDbQueries {
    /// Get activity name for OstTransaction
    ///
    /// - Returns: Activity name
    override func activityName() -> String{
        return "transactions"
    }
}
