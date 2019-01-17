//
//  OstRuleEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRule: OstBaseEntity {
    
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
