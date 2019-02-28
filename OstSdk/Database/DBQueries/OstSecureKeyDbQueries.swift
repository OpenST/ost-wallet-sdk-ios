//
//  OstSecureKeyDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OstSecureKeyDbQueries: OstBaseDbQueries {

    override func activityName() -> String{
        return "secure_keys"
    }
    
    override func getSelectByIdQuery(_ key: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE key=\"\(key.lowercased())\""
    }
    
    override func getInsertOrUpdateQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (key, data) VALUES (:key, :data)"
    }
    
    override func getDeleteQueryForId(_ key: String) -> String{
        return "DELETE FROM \(activityName()) WHERE key=\"\(key.lowercased())\""
    }
    
    override func getInsertOrUpdateQueryParam(_ params: OstBaseEntity) -> [String: Any] {
        let entityData: [String: Any] = (params as! OstSecureKey).toDictionary()
        let queryParams : [String: Any] = ["key": (params as! OstSecureKey).address.lowercased(),
                                           "data": OstUtils.toEncodedData(entityData)
                                          ]
        return queryParams
        
    }
}
