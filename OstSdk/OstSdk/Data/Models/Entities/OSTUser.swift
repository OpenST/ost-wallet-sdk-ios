//
//  OSTUserEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTUser: OSTBaseEntity {
   
    init(jsonData: [String: Any])throws {
        super.init()
        let (isValidJSON, errorString): (Bool, String?) = validJSON(jsonData)
        if !isValidJSON{
            throw EntityErrors.validationError("Invalid JSON passed. error:\(errorString!)")
        }
        setJsonValues(jsonData)
    }
}

public extension OSTUser {
    var name: String? {
        return data["name"] as? String ?? nil
    }
    
    var token_holder_id: String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var multisig: String? {
        return data["multisig"] as? String ?? nil
    }
    
    var token_id: String? {
        return data["token_id"] as? String ?? nil
    }
    
    var status: String? {
        return data["status"] as? String ?? nil
    }
}
