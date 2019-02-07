//
//  RegisterDevice.swift
//  Example
//
//  Created by aniket ayachit on 04/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class RegisterDevice {
    var userId: String
    init(userId: String) {
        self.userId = userId
    }

    func perform() throws {
        let delegate = OstWorkFlowCallbackImplementation()
        
        do {
            try OstSdk.registerDevice(userId: userId, delegate: delegate)
        }catch let error {
            print(error)
        }
    }
}
