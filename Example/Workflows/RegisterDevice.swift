//
//  RegisterDevice.swift
//  Example
//
//  Created by aniket ayachit on 04/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class RegisterDevice: WorkflowBase {
    
    override init(userId: String, tokenId: String, mappyUserId: String) {
        super.init(userId: userId, tokenId: tokenId, mappyUserId: mappyUserId)
    }
    
    override func perform() throws {
        do {
            try OstSdk.registerDevice(userId: userId, tokenId: tokenId, delegate: delegate)
        }catch let error {
            print(error)
        }
    }
}
