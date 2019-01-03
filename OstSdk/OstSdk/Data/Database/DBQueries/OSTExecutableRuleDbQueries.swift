//
//  OSTExecutableRuleDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTExecutableRuleDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTExecutableRule) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTExecutableRule>) -> (Array<OSTExecutableRule>?, Array<OSTExecutableRule>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTExecutableRule>) ?? nil , (failuarArray as? Array<OSTExecutableRule>) ?? nil)
    }
    
    override func activityName() -> String{
        return "executable_rule_entities"
    }
}
