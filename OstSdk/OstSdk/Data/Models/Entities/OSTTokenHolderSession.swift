//
//  OSTTokenHolderSessionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTTokenHolderSession: OSTBaseEntity {
    init(jsonData: [String: Any])throws {
        super.init()
        let (isValidJSON, errorString): (Bool, String?) = validJSON(jsonData)
        if !isValidJSON{
            throw EntityErrors.validationError("Invalid JSON passed. error:\(errorString!)")
        }
        setJsonValues(jsonData)
    }
}

public extension OSTTokenHolderSession {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var token_holder_id : String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var blockHeight : String? {
        return data["blockHeight"] as? String ?? nil
    }
    
    var expiry_time : String? {
        return data["expiry_time"] as? String ?? nil
    }
    
    var spending_limit : String? {
        return data["spending_limit"] as? String ?? nil
    }
    
    var redemption_limit : String? {
        return data["redemption_limit"] as? String ?? nil
    }
    
    var status : String? {
        return data["status"] as? String ?? nil
    }
}
