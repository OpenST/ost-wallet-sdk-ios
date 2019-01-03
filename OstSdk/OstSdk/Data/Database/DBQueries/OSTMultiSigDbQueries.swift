//
//  OSTMultiSigDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTMultiSig) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTMultiSig>) -> (Array<OSTMultiSig>?, Array<OSTMultiSig>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTMultiSig>) ?? nil , (failuarArray as? Array<OSTMultiSig>) ?? nil)
    }
    
    override func activityName() -> String{
        return "multi_sig"
    }
}
