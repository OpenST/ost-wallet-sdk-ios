//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkFlowFactory {
    
    class func registerDevice(userId: String, tokenId: String, forceSync: Bool, delegate: OstWorkFlowCallbackProtocol) throws -> OstRegisterDevice {
        let registerDeviceObj = try OstRegisterDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegat: delegate)
        registerDeviceObj.perform()
        return registerDeviceObj
    }

    class func activateUser(userId: String, uPin: String, password: String, spendingLimit: String,
                            expirationHeight:String, delegate: OstWorkFlowCallbackProtocol) throws {
        
        let activateUserObj = OstActivateUser(userId: userId, uPin: uPin, password: password, spendingLimit: spendingLimit, expirationHeight: expirationHeight, delegate: delegate)
        activateUserObj.perform()
    }
    
}
