//
//  OstMultiSigOperationDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigOperationDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstMultiSigOperation) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstMultiSigOperation>) -> (Array<OstMultiSigOperation>?, Array<OstMultiSigOperation>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstMultiSigOperation>) ?? nil , (failuarArray as? Array<OstMultiSigOperation>) ?? nil)
    }
    
    override func activityName() -> String{
        return "executable_rules"
    }
}
