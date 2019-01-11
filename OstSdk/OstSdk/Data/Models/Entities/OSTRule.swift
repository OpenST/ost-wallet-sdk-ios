//
//  OSTRuleEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTRule: OSTBaseEntity {
    
    init(jsonData: [String: Any])throws {
        super.init()
        let (isValidJSON, errorString): (Bool, String?) = validJSON(jsonData)
        if !isValidJSON{
            throw EntityErrors.validationError("Invalid JSON passed. error:\(errorString!)")
        }
        setJsonValues(jsonData)
    }
}

public extension OSTRule {
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
    
    var status: String? {
        return data["status"] as? String ?? nil
    }
}
