//
//  OSTTokenHolderDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenHolderDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTTokenHolder) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTTokenHolder>) -> (Array<OSTTokenHolder>?, Array<OSTTokenHolder>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTTokenHolder>) ?? nil , (failuarArray as? Array<OSTTokenHolder>) ?? nil)
    }
    
    override func activityName() -> String{
        return "token_holders"
    }
}
