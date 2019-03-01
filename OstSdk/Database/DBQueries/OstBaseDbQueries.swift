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
    
    /// Initializer
    init() {
        db = getDb()
        dbQueue = getDbQueue()
    }
    
    /// Get DB instance
    ///
    /// - Returns: FMDatabase instance
    func getDb() -> FMDatabase {
        return OstSdkDatabase.sharedInstance.database
    }
    
    /// Get DB queue
    ///
    /// - Returns: FMDatabaseQueue instance
    func getDbQueue() -> FMDatabaseQueue {
        return OstSdkDatabase.sharedInstance.databaseQueue!
    }
    
    //MARK: - override
    //************************************* Methods to override *************************************
    internal func activityName() -> String{
        fatalError("activityName did not override in \(self)")
    }
    //************************************ Methods to override end ***********************************
    
    
    /// Get item from DB for given id
    ///
    /// - Parameter id: id string
    /// - Returns: Dictionary
    /// - Throws: OSTError
    func getById(_ id: String) throws -> [String: Any?]? {
        let selectByIdQuery = getSelectByIdQuery(id)
        let dbResult = try executeQuery(selectByIdQuery)
        return dbResult?.first
    }
    
    /// Get item from DB for given parent id
    ///
    /// - Parameter id: Parent id
    /// - Returns:  Array<[String: Any?]>, Array of dictionary
    /// - Throws: OSTError
    func getByParentId(_ id: String) throws -> Array<[String: Any?]>? {
        let selectByParentIdQuery = getSelectByParentIdQuery(id)
        return try executeQuery(selectByParentIdQuery)
    }
    
    /// Insert or update DB
    ///
    /// - Parameter entity: Entity object
    /// - Returns: `true` if success otherwise `false`
    func insertOrUpdate(_ entity: OstBaseEntity, onUpdate:@escaping ((Bool) -> Void)) {
        let insertOrUpdateQuery = getInsertOrUpdateQuery()
        let queryParam = getInsertOrUpdateQueryParam(entity)
        executeUpdate(insertOrUpdateQuery, values: queryParam, onUpdate: onUpdate)
    }
    
    /// Delete item from id
    ///
    /// - Parameter id: Id string
    /// - Returns: `true` if deleted otherwise `false`
    func deleteForId(_ id: String) -> Bool {
        let deleteQuery = getDeleteQueryForId(id)
        return executeStatements(deleteQuery)
    }
    
    // MARK: - Execute

    /// Execute query
    ///
    /// - Parameter query: Query string
    /// - Returns: Array<[String: Any?]>, Array of dictionary
    /// - Throws: OstError
    func executeQuery(_ query: String) throws -> Array<[String: Any?]>? {
        do {
            if let resultSet: FMResultSet = try db?.executeQuery(query, values: nil) ?? nil {
                let result = getEntityDataFromResultSet(resultSet)
                return result
            }
            return nil
        } catch {
            throw OstError("d_dbq_bdq_eq_1", .dbExecutionFailed)
        }
    }
    
    /// Execute batch statements
    ///
    /// - Parameter query: Query string
    /// - Returns: `true` if succcessful otherwise `false`
    func executeStatements(_ query: String) -> Bool {
        return db?.executeStatements(query) ?? false
    }
    
    /// Execute update query
    ///
    /// - Parameters:
    ///   - query: Query string
    ///   - values: Value that needs to be updated
    /// - Returns: `true` if succcessful otherwise `false`
    func executeUpdate(_ query: String, values: [String: Any], onUpdate:@escaping ((Bool) -> Void)){
        dbQueue?.inTransaction({ (fmdb, nil) in
            let updateResult:Bool  = fmdb.executeUpdate(query, withParameterDictionary: values)
            onUpdate(updateResult)
        })
    }
    
    // MARK: - Database Structure
    
    /// Create DB query object from Entity object
    ///
    /// - Parameter params: Entity object
    /// - Returns: Dictionary representing the query object
    func getInsertOrUpdateQueryParam(_ params: OstBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = [OstBaseDbQueries.ID: params.id.lowercased(),
                                           OstBaseDbQueries.PARENT_ID: params.parentId?.lowercased() ?? "",
                                           OstBaseDbQueries.DATA: OstUtils.toEncodedData(params.data),
                                           OstBaseDbQueries.UTS: params.updatedTimestamp,
                                           OstBaseDbQueries.STATUS: params.status ?? ""
        ]
        return queryParams
    }
    
    /// Get entity data from db result set
    ///
    /// - Parameter resultSet: FMResultSet object
    /// - Returns: Array of dictionary items from the result result
    func getEntityDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
        var resultData: Array<[String: Any]> = []
        
        while resultSet.next() {
            let decodedData: [String: Any] = OstUtils.toDecodedValue(Data(resultSet.data(forColumn: "data")!)) as! [String: Any]
            resultData.append(decodedData)
        }
        return resultData
    }
    
    //MARK: - Query string
    
    /// Get the select from id query string
    ///
    /// - Parameter id: Id string
    /// - Returns: Query string
    func getSelectByIdQuery(_ id: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE id=\"\(id.lowercased())\""
    }
    
    /// Get the select from parent id query string
    ///
    /// - Parameter id: Patent id string
    /// - Returns: Query string
    fileprivate func getSelectByParentIdQuery(_ parentId: String) -> String {
        let query: String = "SELECT * FROM \(activityName()) WHERE parent_id=\"\(parentId.lowercased())\""
        return query
    }
    
    /// Get insert or update query string
    ///
    /// - Returns: Query string
    func getInsertOrUpdateQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (id, parent_id, data, status, uts) VALUES (:id, :parent_id, :data, :status, :uts)"
    }
    
    /// Get delete query string
    ///
    /// - Parameter id: Id string
    /// - Returns: Query string
    func getDeleteQueryForId(_ id: String) -> String{
        return "DELETE FROM \(activityName()) WHERE id=\"\(id.lowercased())\""
    }
}
