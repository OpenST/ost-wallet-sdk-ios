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
    
    static func getEntityIdentifer() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstRule ?? nil
    }
    
  
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstRule.getEntityIdentifer()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstRule.OSTRULE_PARENTID])
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
