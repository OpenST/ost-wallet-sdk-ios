//
//  ActivateUser.swift
//  Example
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class ActivateUser: WorkflowBase {
    
    let pin: String
    let password: String
    init(userId: String, tokenId: String, mappyUserId: String, pin: String, password: String) {
        self.pin = pin
        self.password = password
        
        super.init(userId: userId, tokenId: tokenId, mappyUserId: mappyUserId)
    }
    
    override func perform() throws {
        OstSdk.activateUser(userId: userId, pin: pin, password: password, spendingLimit: "100000000", expirationHeight: 123343, delegate: delegate)
    }
}
