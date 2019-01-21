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

    override func getDb() -> FMDatabase {
        return OstSdkKeyDatabase.sharedInstance.database
    }
    
    override func activityName() -> String{
        return "secure_keys"
    }
    
    override func getSelectByIdQuery(_ key: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE key=\"\(key)\""
    }
    
    override func getInsertOrUpdateQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (key, data) VALUES (:key, :data)"
    }
    
    override func getDeleteQueryForId(_ key: String) -> String{
        return "DELETE FROM \(activityName()) WHERE key=\"\(key)\""
    }
    
    override func getInsertOrUpdateQueryParam(_ params: OstBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = ["key": (params as! OstSecureKey).key,
                                           "data": (params as! OstSecureKey).secData
                                          ]
        return queryParams
    }
    
    override func getEntityDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
        var resultData: Array<[String: Any]> = []
        
        while resultSet.next() {
            let dDataVal: Data = resultSet.data(forColumn: "data")!
            let keyVal: String = resultSet.string(forColumn: "key")!
            let r: [String: Any] = ["key": keyVal, "data": dDataVal]
            resultData.append(r)
        }
        
        return resultData
    }
}
