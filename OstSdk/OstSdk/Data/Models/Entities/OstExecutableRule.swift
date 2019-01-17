//
//  OstExecutableRuleEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstExecutableRule: OstBaseEntity {

}

public extension OstExecutableRule {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var token_holder_address : String? {
        return data["token_holder_address"] as? String ?? nil
    }
    
    var rule_id : String? {
        return data["rule_id"] as? String ?? nil
    }
    
    var method : String? {
        return data["method"] as? String ?? nil
    }
    
    var params : String? {
        return data["params"] as? String ?? nil
    }
    
    var session : String? {
        return data["session"] as? String ?? nil
    }
    
    var execute_rule_payload : [String: String]? {
        return data["execute_rule_payload"] as? [String:String] ?? nil
    }
}
