//
//  OSTTokenDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTToken) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTToken>) -> (Array<OSTToken>?, Array<OSTToken>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTToken>) ?? nil , (failuarArray as? Array<OSTToken>) ?? nil)
    }
    
    override func activityName() -> String{
        return "economies"
    }
}
