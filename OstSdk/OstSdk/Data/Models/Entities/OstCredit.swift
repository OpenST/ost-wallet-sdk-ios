//
//  OstCredit.swift
//  OstSdk
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstCredit: OstBaseEntity {
    
    static func getEntityIdentifer() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstCredit? {
        return try OstCreditRepository.sharedCredit.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstCredit ?? nil
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstCredit.getEntityIdentifer()])!
    }
}


extension OstCredit {
    
    var amount: Int? {
        return OstUtils.toInt(data["amount"] as Any?)
    }
    
    var user_ids: [String]? {
        return data["user_ids"] as? Array<String>
    }
}
