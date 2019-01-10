//
//  OSTSecureKeyDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTSecureKeyDbQueries: OSTBaseDbQueries {

    override func getDb() -> FMDatabase {
        return OSTSdkKeyDatabase.sharedInstance.database
    }
    
    override func activityName() -> String{
        return "secure_keys"
    }
    
    func save(_ entity: OSTSecureKey) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    override func getSelectQueryById(_ key: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE key=\"\(key)\""
    }
    
    override func getInsertQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (key, data) VALUES (:key, :data)"
    }
    
    override func getDeleteQueryForId(_ key: String) -> String{
        return "DELETE FROM \(activityName()) WHERE key=\"\(key)\""
    }
    
    override func getInsertQueryParam(_ params: OSTBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = ["key": (params as! OSTSecureKey).key,
                                           "data": (params as! OSTSecureKey).secData
                                          ]
        return queryParams
    }
    
    override func getDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
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
