//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension OstSdk {
    //MARK: - Workflow
    
    /// setup device for user.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - tokenId: Token identifier for user.
    ///   - forceSync: Force sync data from Kit.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func setupDevice(userId: String, tokenId: String, forceSync: Bool = false, delegate: OstWorkFlowCallbackProtocol) {
        let registerDeviceObj = OstRegisterDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegat: delegate)
        registerDeviceObj.perform()
    }
    
    /// Once device setup is completed, call active user to deploy token holder.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - pin: user secret pin.
    ///   - password: App-server secret for user.
    ///   - spendingLimit: Max amount that user can spend per transaction.
    ///   - expirationHeight:
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func activateUser(userId: String, pin: String, password: String, spendingLimit: String,
                                   expirationHeight: Int, delegate: OstWorkFlowCallbackProtocol) {
        let activateUserObj = OstActivateUser(userId: userId, pin: pin, password: password, spendingLimit: spendingLimit, expirationHeight: expirationHeight, delegate: delegate)
        activateUserObj.perform()
    }
    
    /// Add device
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Ost user identifier.
    public class func addDevice(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        let addDeviceObject = OstAddDevice(userId: userId, delegate: delegate)
        addDeviceObject.perform()
    }
    
    public class func perform(userId: String, ciImage qrCodeImage: CIImage, delegate: OstWorkFlowCallbackProtocol) {
        
    }
    
    public class func pefrom(userId: String, image qrCodeImage: UIImage, delegate: OstWorkFlowCallbackProtocol) {
        
    }
    
    public class func perfrom(userId: String, payload: String, delegate: OstWorkFlowCallbackProtocol) {
        
    }
}
