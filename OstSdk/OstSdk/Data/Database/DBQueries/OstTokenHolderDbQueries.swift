//
//  OstTokenHolderDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstTokenHolder) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstTokenHolder>) -> (Array<OstTokenHolder>?, Array<OstTokenHolder>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstTokenHolder>) ?? nil , (failuarArray as? Array<OstTokenHolder>) ?? nil)
    }
    
    override func activityName() -> String{
        return "token_holders"
    }
}
