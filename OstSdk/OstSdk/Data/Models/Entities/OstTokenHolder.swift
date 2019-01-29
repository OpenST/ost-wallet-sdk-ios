//
//  OstTokenHolderEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTokenHolder: OstBaseEntity {
    static func parse(_ entityData: [String: Any?]) throws -> OstTokenHolder? {
        return try OstTokenHolderRepository.sharedTokenHolder.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstTokenHolder ?? nil
    }
    
    static func getEntityIdentifer() -> String {
        return "id"
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstUser.getEntityIdentifer()])!
    }
}

public extension OstTokenHolder {
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var multisig_id : String? {
        return data["multisig_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var sessions : Array<String>? {
        return data["sessions"] as? Array<String> ?? nil
    }
    
    var execute_rule_callprefix : String? {
        return data["execute_rule_callprefix"] as? String ?? nil
    }
}
