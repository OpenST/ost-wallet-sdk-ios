//
//  OSTMultiSigOperationEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTMultiSigOperation: OSTBaseEntity {
    public init(jsonData: [String: Any])throws {
        super.init()
        if !validJSON(jsonData){
            throw EntityErrors.validationError("Invalid JSON passed.")
        }
        setJsonValues(jsonData)
    }
}


extension OSTMultiSigOperation {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var token_holder_address : String? {
        return data["token_holder_address"] as? String ?? nil
    }
    
    var kind : String? {
        return data["kind"] as? String ?? nil
    }
    
    var encoded_data : String? {
        return data["encoded_data"] as? String ?? nil
    }
    
    var raw_data : [String: Any]? {
        return data["raw_data"] as? [String: Any] ?? nil
    }
    
    var status : String? {
        return data["status"] as? String ?? nil
    }
    
    var signatures : [String: String]? {
        return data["signatures"] as? [String: String] ?? nil
    }
}
