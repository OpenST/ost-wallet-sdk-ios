//
//  OstTokenHolderSessionDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderSessionDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstTokenHolderSession) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstTokenHolderSession>) -> (Array<OstTokenHolderSession>?, Array<OstTokenHolderSession>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstTokenHolderSession>) ?? nil , (failuarArray as? Array<OstTokenHolderSession>) ?? nil)
    }
    
    override func activityName() -> String{
        return "token_holder_sessions"
    }
}
