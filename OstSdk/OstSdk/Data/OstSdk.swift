//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {
    private init() {}
    
    public static func getUser(_ id: String) throws -> OSTUser? {
        return try OSTUserModelRepository.sharedUser.get(id)
    }
    
    public static func initUser(_ userJson: [String: Any], success: ((OSTUser?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTUserModelRepository.sharedUser.save(userJson, success: success, failure: failure)
    }
    
    public static func getRule(_ id: String) throws -> OSTRule? {
        return try OSTRuleModelRepository.sharedRule.get(id)
    }
    
    public static func initRule(_ ruleJson: [String: Any], success: ((OSTRule?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTRuleModelRepository.sharedRule.save(ruleJson, success: success, failure: failure)
    }
    
    public static func getTokenHolder(_ id: String) throws -> OSTTokenHolder? {
        return try OSTTokenHolderRepository.sharedTokenHolder.get(id)
    }
    
    public static func initTokenHolder(_ tokenHolderJson: [String: Any], success: ((OSTTokenHolder?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTTokenHolderRepository.sharedTokenHolder.save(tokenHolderJson, success: success, failure: failure)
    }
}
