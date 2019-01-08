//
//  OSTMultiSigEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTMultiSig: OSTBaseEntity {
    init(jsonData: [String: Any])throws {
        super.init()
        let (isValidJSON, errorString): (Bool, String?) = validJSON(jsonData)
        if !isValidJSON{
            throw EntityErrors.validationError("Invalid JSON passed. error:\(errorString!)")
        }
        setJsonValues(jsonData)
    }
}

public extension OSTMultiSig {
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var token_holder_id : String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var wallets : Array<String>? {
        return data["wallets"] as? Array<String> ?? nil
    }
    
    var requirement: String? {
        return data["requirement"] as? String ?? nil
    }
    
    var authorize_session_callprefix: String? {
        return data["authorize_session_callprefix"] as? String ?? nil
    }
}
