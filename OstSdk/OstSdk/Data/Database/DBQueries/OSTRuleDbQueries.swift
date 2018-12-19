//
//  OSTRuleDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTRuleDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTRule) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTRule>) -> (Array<OSTRule>?, Array<OSTRule>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTRule>) ?? nil , (failuarArray as? Array<OSTRule>) ?? nil)
    }
    
    override func activityName() -> String{
        return "rules"
    }
}
