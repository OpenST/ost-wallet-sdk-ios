//
//  UserDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTUserDbQueries: OSTBaseDbQueries {
   
    func save(_ entity: OSTUser) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }

    func saveAll(_ entities: Array<OSTUser>) -> (Array<OSTUser>?, Array<OSTUser>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTUser>) ?? nil , (failuarArray as? Array<OSTUser>) ?? nil)
    }
    
    override func activityName() -> String{
        return "users"
    }
}
