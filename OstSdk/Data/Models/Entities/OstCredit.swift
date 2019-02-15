//
//  OstCredit.swift
//  OstSdk
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstCredit: OstBaseEntity {
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }
    
    static func parse(_ entityData: [String: Any?]) throws -> OstCredit? {
        return try OstCreditRepository.sharedCredit.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstCredit
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstCredit.getEntityIdentiferKey()] as Any?)!
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
