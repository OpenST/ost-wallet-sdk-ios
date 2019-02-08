//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkFlowFactory {
    
    class func registerDevice(userId: String, tokenId: String, delegate: OstWorkFlowCallbackProtocol) throws -> OstRegisterDevice {
        let registerDeviceObj = try OstRegisterDevice(userId: userId, tokenId: tokenId, delegat: delegate)
        registerDeviceObj.perform()
        return registerDeviceObj
    }

    class func deployTokenHolder(userId: String, spendingLimit: String, expirationHeight:String, delegate: OstWorkFlowCallbackProtocol) throws {
        let deployTokenHolderObj = OstDeployTokenHolder(userId: userId, spendingLimit: spendingLimit, expirationHeight: expirationHeight, delegate: delegate)
        deployTokenHolderObj.perform()
    }
    
}
