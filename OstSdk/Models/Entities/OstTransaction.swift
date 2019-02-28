//
//  OstTransactionEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstTransaction: OstBaseEntity {
    
    enum Status: String {
        case CREATED = "CREATED"
        case FAILED = "FAILED"
        case SUCCESS = "SUCCESS"
    }
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstTransaction? {
        return try OstTransactionRepository.sharedTransaction.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstTransaction
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstTransaction.getEntityIdentiferKey()] as Any?)!
    }
}

public extension OstTransaction {
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
    
    var gas_price: Int? {
        return OstUtils.toInt(data["gas_price"] as Any?) 
    }
}

//Get transaction status
public extension OstTransaction {
    var isStatusSuccess: Bool {
        if let status: String = self.status {
            return (OstTransaction.Status.SUCCESS.rawValue == status)
        }
        return false
    }
    
    var isStatusFailed: Bool {
        if let status: String = self.status {
            return (OstTransaction.Status.FAILED.rawValue == status)
        }
        return false
    }
}
