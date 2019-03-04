//
//  OstWorkflowHelperBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkflowHelperBase {
    
    let userId: String
    
    var currentUser: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    
    init (userId: String) {
        self.userId = userId
    }
}
