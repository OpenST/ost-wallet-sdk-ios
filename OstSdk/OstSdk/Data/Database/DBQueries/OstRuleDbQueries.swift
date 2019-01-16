//
//  OstRuleDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstRuleDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstRule) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstRule>) -> (Array<OstRule>?, Array<OstRule>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstRule>) ?? nil , (failuarArray as? Array<OstRule>) ?? nil)
    }
    
    override func activityName() -> String{
        return "rules"
    }
}
