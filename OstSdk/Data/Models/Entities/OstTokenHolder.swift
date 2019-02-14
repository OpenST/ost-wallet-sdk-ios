//
//  OstTokenHolderEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTokenHolder: OstBaseEntity {
    
    static let OSTTOKEN_HOLDER_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstTokenHolder? {
        return try OstTokenHolderRepository.sharedTokenHolder.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstTokenHolder
    }
    
    static func getEntityIdentiferKey() -> String {
        return "address"
    }
    
    override func getId() -> String {
        return OstUtils.toString(self.data[OstTokenHolder.getEntityIdentiferKey()] as Any?)!
    }
    
    override func getParentId() -> String? {
        return OstUtils.toString(self.data[OstTokenHolder.OSTTOKEN_HOLDER_PARENTID] as Any?)
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
