//
//  OstMultiSigDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstMultiSig) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstMultiSig>) -> (Array<OstMultiSig>?, Array<OstMultiSig>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstMultiSig>) ?? nil , (failuarArray as? Array<OstMultiSig>) ?? nil)
    }
    
    override func activityName() -> String{
        return "multi_sig"
    }
}
