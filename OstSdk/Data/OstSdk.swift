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
    
    public static func parse(_ apiResponse: [String: Any]) throws {
        if let device: [String: Any] = apiResponse["device"] as? [String : Any] {
             _ = try OstDevice.parse(device)
        }
        
        if let user: [String: Any] = apiResponse["user"] as? [String: Any] {
            _ = try OstUser.parse(user)
        }
    }
    
    public static func getUser(_ id: String) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.getById(id) as? OstUser
    }
    
    public static func initUser(forId id: String) throws -> OstUser? {
        let entityData: [String: Any] = ["id": id]
        return try parseUser(entityData)
    }
    
    public static func parseUser(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUser.parse(entityData);
    }
    
    public static func parseUser(_ jsonString: String) throws -> OstUser? {
        let entityData = try OstUtils.toJSONObject(jsonString) as! [String: Any?]
        return try parseUser(entityData)
    }
    
    public static func getRule(_ id: String) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.getById(id) as? OstRule
    }
    
    public static func registerDevice(userId: String, tokenId: String, delegate: OstWorkFlowCallbackProtocol) throws {
        _ = try OstWorkFlowFactory.registerDevice(userId: userId, tokenId: tokenId, delegate: delegate)
    }
    
    public static func deployTokenHolder(userId: String, spendingLimit: String, expirationHeight:String, delegate: OstWorkFlowCallbackProtocol) throws {
        try OstWorkFlowFactory.deployTokenHolder(userId: userId, spendingLimit: spendingLimit, expirationHeight:expirationHeight, delegate: delegate)
    }
}
