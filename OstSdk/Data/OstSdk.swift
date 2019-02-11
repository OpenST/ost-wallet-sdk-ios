//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {
    
    init() {}
    
    public class func parse(_ apiResponse: [String: Any]) throws {
        if let device: [String: Any] = apiResponse["device"] as? [String : Any] {
             _ = try OstDevice.parse(device)
        }
        
        if let user: [String: Any] = apiResponse["user"] as? [String: Any] {
            _ = try OstUser.parse(user)
        }
    }
    
    public class func getUser(_ id: String) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.getById(id) as? OstUser
    }
    
    public class func initUser(forId id: String, withTokenId tokenId: String) throws -> OstUser? {
        let entityData: [String: Any] = [OstUser.getEntityIdentiferKey(): id, "token_id": tokenId]
        return try parseUser(entityData)
    }
    
    public class func parseUser(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUser.parse(entityData);
    }
    
    public class func parseUser(_ jsonString: String) throws -> OstUser? {
        let entityData = try OstUtils.toJSONObject(jsonString) as! [String: Any?]
        return try parseUser(entityData)
    }
    
    public class func initToken(_ tokenId: String) throws -> OstToken? {
        let entityData: [String: Any] = [OstToken.getEntityIdentiferKey(): tokenId]
        return try OstToken.parse(entityData)
    }
    
    
    public class func getRule(_ id: String) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.getById(id) as? OstRule
    }
    
    
    
    
    
    
    
    public class func setupDevice(userId: String, tokenId: String, forceSync: Bool = false, delegate: OstWorkFlowCallbackProtocol) throws {
        _ = try OstWorkFlowFactory.registerDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegate: delegate)
    }
    
    public class func deployTokenHolder(userId: String, spendingLimit: String, expirationHeight:String, delegate: OstWorkFlowCallbackProtocol) throws {
        try OstWorkFlowFactory.deployTokenHolder(userId: userId, spendingLimit: spendingLimit, expirationHeight:expirationHeight, delegate: delegate)
    }
}
