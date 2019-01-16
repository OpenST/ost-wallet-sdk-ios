//
//  UserDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstUserDbQueries: OstBaseDbQueries {
   
    func save(_ entity: OstUser) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }

    func saveAll(_ entities: Array<OstUser>) -> (Array<OstUser>?, Array<OstUser>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstUser>) ?? nil , (failuarArray as? Array<OstUser>) ?? nil)
    }
    
    override func activityName() -> String{
        return "users"
    }
}
