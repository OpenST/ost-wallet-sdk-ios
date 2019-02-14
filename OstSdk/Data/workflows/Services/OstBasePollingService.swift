//
//  OstPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 13/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstBasePollingService {
    
    var maxRetryCount = 10
    let firstDelayTime = OstConstants.OST_BLOCK_FORMATION_TIME + 6
    
    let userId: String
    
    init (userId: String) {
        self.userId = userId
    }
    
    func perform() {
        fatalError("perform did not override.")
    }
}
