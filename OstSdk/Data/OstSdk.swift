//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {

    public class func initialize() {
        _ = OstSdkDatabase.sharedInstance
    }
    
    public class func parse(_ apiResponse: [String: Any?]) throws {
        _ = try self.parseApiResponse(apiResponse)
    }
    
    class func parseApiResponse(_ apiResponse: [String: Any?]) throws -> OstBaseEntity? {
        
        let resultType = apiResponse["result_type"] as? String ?? ""
        let entityData =  apiResponse[resultType] as? [String: Any?]
        
        if (entityData == nil) {
            throw OstError.actionFailed("parsing \(resultType) enity failed.")
        }
        switch resultType {
        case "token":
            return try OstToken.parse(entityData!)
        case "user":
            return try OstUser.parse(entityData!)
        case "device":
            return try OstDevice.parse(entityData!)
        case "device_manager":
            return try OstDeviceManager.parse(entityData!)
        case "session":
            return try OstSession.parse(entityData!)
        default:
            throw OstError.invalidInput("\(resultType) is not supported.")
        }
    }
    
    public class func getUser(_ id: String) throws -> OstUser? {
        return try OstUser.getById(id)
    }
    
    public class func initUser(forId id: String, withTokenId tokenId: String) throws -> OstUser? {
        let entityData: [String: Any] = [OstUser.getEntityIdentiferKey(): id, "token_id": tokenId, "status": OstUser.USER_STATUS_CREATED]
        return try parseUser(entityData)
    }
    
    public class func parseUser(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUser.parse(entityData);
    }
    
    public class func initToken(_ tokenId: String) throws -> OstToken? {
        let entityData: [String: Any] = [OstToken.getEntityIdentiferKey(): tokenId]
        return try OstToken.parse(entityData)
    }
    
    //MARK: - Workflow

    /// setup device for user.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - tokenId: Token identifier for user.
    ///   - forceSync: Force sync data from Kit.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func setupDevice(userId: String, tokenId: String, forceSync: Bool = false, delegate: OstWorkFlowCallbackProtocol) {
        OstWorkFlowFactory.registerDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegate: delegate)
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
        OstWorkFlowFactory.activateUser(userId: userId, pin: pin, password: password, spendingLimit: spendingLimit,
                                            expirationHeight:expirationHeight, delegate: delegate)
    }
    
    public class func addDevice(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        
    }
}
