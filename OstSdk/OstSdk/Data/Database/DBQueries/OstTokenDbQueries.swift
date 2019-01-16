//
//  OstTokenDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstToken) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstToken>) -> (Array<OstToken>?, Array<OstToken>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstToken>) ?? nil , (failuarArray as? Array<OstToken>) ?? nil)
    }
    
    override func activityName() -> String{
        return "economies"
    }
}
