//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkFlowFactory {
    
    class func registerDevice(userId: String, tokenId: String, forceSync: Bool, delegate: OstWorkFlowCallbackProtocol) {
        let registerDeviceObj = OstRegisterDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegat: delegate)
        registerDeviceObj.perform()
    }

    class func activateUser(userId: String, pin: String, password: String, spendingLimit: String,
                            expirationHeight: Int, delegate: OstWorkFlowCallbackProtocol) {
        
        let activateUserObj = OstActivateUser(userId: userId, pin: pin, password: password, spendingLimit: spendingLimit, expirationHeight: expirationHeight, delegate: delegate)
        activateUserObj.perform()
    }
    
    class func addDevice(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        let addDeviceObject = OstAddDevice(userId: userId, delegate: delegate)
        addDeviceObject.perform()
    }
    
}
