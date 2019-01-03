//
//  OSTTokenHolderSessionDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenHolderSessionDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTTokenHolderSession) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTTokenHolderSession>) -> (Array<OSTTokenHolderSession>?, Array<OSTTokenHolderSession>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTTokenHolderSession>) ?? nil , (failuarArray as? Array<OSTTokenHolderSession>) ?? nil)
    }
    
    override func activityName() -> String{
        return "token_holder_sessions"
    }
}
