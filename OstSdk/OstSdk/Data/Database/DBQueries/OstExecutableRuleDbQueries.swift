//
//  OstExecutableRuleDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstExecutableRuleDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstExecutableRule) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstExecutableRule>) -> (Array<OstExecutableRule>?, Array<OstExecutableRule>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstExecutableRule>) ?? nil , (failuarArray as? Array<OstExecutableRule>) ?? nil)
    }
    
    override func activityName() -> String{
        return "executable_rule_entities"
    }
}
