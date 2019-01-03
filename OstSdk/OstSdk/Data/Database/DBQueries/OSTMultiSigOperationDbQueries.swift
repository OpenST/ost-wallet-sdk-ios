//
//  OSTMultiSigOperationDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigOperationDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTMultiSigOperation) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTMultiSigOperation>) -> (Array<OSTMultiSigOperation>?, Array<OSTMultiSigOperation>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTMultiSigOperation>) ?? nil , (failuarArray as? Array<OSTMultiSigOperation>) ?? nil)
    }
    
    override func activityName() -> String{
        return "executable_rules"
    }
}
