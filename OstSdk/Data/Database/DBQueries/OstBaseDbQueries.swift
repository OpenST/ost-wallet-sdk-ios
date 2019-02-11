//
//  BaseDbQuery.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OstBaseDbQueries {
    
    static let ID = "id"
    static let PARENT_ID = "parent_id"
    static let DATA = "data"
    static let STATUS = "status"
    static let UTS = "uts"
    
    static let queue = DispatchQueue(label: "db", qos: .background, attributes: .concurrent)
    weak var dbQueue: FMDatabaseQueue?
    weak var db: FMDatabase?
    init() {
        db = getDb()
        dbQueue = getDbQueue()
    }
    
    func getDb() -> FMDatabase {
        return OstSdkDatabase.sharedInstance.database
    }
    
    func getDbQueue() -> FMDatabaseQueue {
        return OstSdkDatabase.sharedInstance.databaseQueue!
    }
    
    //MARK: - override
    //************************************* Methods to override *************************************
    internal func activityName() -> String{
        fatalError("activityName did not override in \(self)")
    }
    //************************************ Methods to override end ***********************************
    
    // MARK: - new code
    func getById(_ id: String) throws -> [String: Any?]? {
        let selectByIdQuery = getSelectByIdQuery(id)
        let dbResult = try executeQuery(selectByIdQuery)
        return dbResult?.first
    }
    
    func getByParentId(_ id: String) throws -> Array<[String: Any?]>? {
        let selectByParentIdQuery = getSelectByParentIdQuery(id)
        return try executeQuery(selectByParentIdQuery)
    }
    
    func insertOrUpdate(_ entity: OstBaseEntity) -> Bool {
        let insertOrUpdateQuery = getInsertOrUpdateQuery()
        let queryParam = getInsertOrUpdateQueryParam(entity)
        return executeUpdate(insertOrUpdateQuery, values: queryParam)
    }
    
    func deleteForId(_ id: String) -> Bool {
        let deleteQuery = getDeleteQueryForId(id)
        return executeStatement(deleteQuery)
    }
    
    // MARK: - Execute
    func executeQuery(_ query: String) throws -> Array<[String: Any?]>? {
        if let resultSet: FMResultSet = try db?.executeQuery(query, values: nil) ?? nil {
            let result = getEntityDataFromResultSet(resultSet)
            return result
        }
        return nil
    }
    
    func executeStatement(_ query: String) -> Bool {
        return db?.executeStatements(query) ?? false
    }
    
    func executeUpdate(_ query: String, values: [String: Any]) -> Bool {
        dbQueue?.inTransaction({ (fmdb, nil) in
            _ = fmdb.executeUpdate(query, withParameterDictionary: values) 
        })
        return true
    }
    
    // MARK: - Database Structure
    func getInsertOrUpdateQueryParam(_ params: OstBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = [OstBaseDbQueries.ID: params.id,
                                           OstBaseDbQueries.PARENT_ID: params.parnetId ?? "",
                                           OstBaseDbQueries.DATA: OstUtils.toEncodedData(params.data),
                                           OstBaseDbQueries.UTS: params.updated_timestamp,
                                           OstBaseDbQueries.STATUS: params.status ?? ""
        ]
        return queryParams
    }
    
    func getEntityDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
        var resultData: Array<[String: Any]> = []
        
        while resultSet.next() {
            let decodedData: [String: Any] = OstUtils.toDecodedValue(Data(resultSet.data(forColumn: "data")!)) as! [String: Any]
            resultData.append(decodedData)
        }
        return resultData
    }
    
    //MARK: - Query string
    func getSelectByIdQuery(_ id: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE id=\"\(id)\""
    }
    
    fileprivate func getSelectByParentIdQuery(_ parentId: String) -> String {
        let query: String = "SELECT * FROM \(activityName()) WHERE parent_id=\"\(parentId)\""
        return query
    }
    
    func getInsertOrUpdateQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (id, parent_id, data, status, uts) VALUES (:id, :parent_id, :data, :status, :uts)"
    }
    
    func getDeleteQueryForId(_ id: String) -> String{
        return "DELETE FROM \(activityName()) WHERE id=\"\(id)\""
    }
}
