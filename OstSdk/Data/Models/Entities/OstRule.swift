//
//  OstRuleEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRule: OstBaseEntity {
    
    static let OSTRULE_PARENTID = "token_id"
    
    static func getEntityIdentiferKey() -> String {
        return "rule_id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstRule
    }
    
  
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstRule.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstRule.OSTRULE_PARENTID] as Any?)
    }
}

public extension OstRule {
    var token_id : String? {
        return data["token_id"] as? String ?? nil
    }
    
    var name : String? {
        return data["name"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var abi : String? {
        return data["abi"] as? String ?? nil
    }
}
