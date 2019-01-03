//
//  OSTEconomyDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTEconomyDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTEconomy) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTEconomy>) -> (Array<OSTEconomy>?, Array<OSTEconomy>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTEconomy>) ?? nil , (failuarArray as? Array<OSTEconomy>) ?? nil)
    }
    
    override func activityName() -> String{
        return "economies"
    }
}
