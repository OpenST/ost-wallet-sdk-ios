//
//  BaseDbQuery.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OstBaseDbQueries: OstDBQueriesProtocol {
    
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
        fatalError("activityName didnot override in \(self)")
    }
    //************************************ Methods to override end ***********************************
    
    //MARK: - db implementaiton
    func selectForId(_ id: String) -> Dictionary<String, Any>? {
        let selectQuery = getSelectQueryById(id)
        
        var resultToReturn: [String: Any]? = nil
        do {
            let resultSet: FMResultSet? = try db?.executeQuery(selectQuery, values: nil) ?? nil
            if resultSet != nil{
                let result = getDataFromResultSet(resultSet!)
                if (result.count > 0) {
                    resultToReturn =  result.first
                }
            }
        }catch {}
        
        return resultToReturn
    }
    
    func selectByParentId(_ parentId: String) -> [[String: Any]]? {
        let selectByParentIdQuery = getSelectByParentIdQuery(parentId)
        var resultToReturn: Array<[String: Any]>? = []
        
        do {
            let resultSet: FMResultSet? = try db?.executeQuery(selectByParentIdQuery, values: nil) ?? nil
            if resultSet != nil{
                let result = getDataFromResultSet(resultSet!)
                if (result.count > 0) {
                    resultToReturn?.append(result.last!)
                }
            }
        }catch {}
        
        return resultToReturn
    }
    
    func selectForIds(_ ids: Array<String>) -> [String: [String:Any]?]? {
        let selectQuery = getSelectQueryByIds(ids)
        do {
            let resultSet: FMResultSet? = try db?.executeQuery(selectQuery, values: nil) ?? nil
            if resultSet != nil{
                let results = getDataFromResultSet(resultSet!)
                var resultHash: [String: [String:Any]?] = [:]
                for result in results {
                    resultHash[result["id"] as! String] = result
                }
                return resultHash
            }
            return nil
        }catch {
            return nil
        }
    }
    
    func insertOrUpdateInDB(params: OstBaseEntity) -> Bool {
        let insertQuery = getInsertQuery()
        let queryParam = getInsertQueryParam(params)
        return db?.executeUpdate(insertQuery, withParameterDictionary: queryParam) ?? false
    }
    
    func bulkInsertOrUpdateInDB(params: Array<OstBaseEntity>) -> (Array<OstBaseEntity>, Array<OstBaseEntity>) {
        let insertQuery: String = getInsertQuery()
        var insertSuccessArray: Array<OstBaseEntity> = Array()
        var insertFailuarArray: Array<OstBaseEntity> = Array()
        for param in params{
            let queryParam = getInsertQueryParam(param)
            let isSuccess: Bool = db?.executeUpdate(insertQuery, withParameterDictionary: queryParam) ?? false
            isSuccess ? insertSuccessArray.append(param) : insertFailuarArray.append(param)
        }
        
        return (insertSuccessArray, insertFailuarArray)
    }
    
    func deleteForId(_ id: String) -> Bool {
        let deleteQuery = getDeleteQueryForId(id)
        let isDeleteSuccess: Bool =  db?.executeStatements(deleteQuery) ?? false
        return isDeleteSuccess
    }
    
    func bulkDeleteForIds(_ ids: Array<String>) -> Bool {
        let deleteQuery = getDeleteQueryForIds(ids)
        let isDeleteSuccess: Bool =  db?.executeStatements(deleteQuery) ?? false
        return isDeleteSuccess
    }
    
    //MARK: - query string
    func getSelectQueryById(_ id: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE id=\"\(id)\""
    }
    
    fileprivate func getSelectQueryByIds(_ ids: Array<String>) -> String {
        let query: String = "SELECT * FROM \(activityName()) WHERE id IN (\(ids.joined(separator: ",")))"
        return query
    }
    
    fileprivate func getSelectByParentIdQuery(_ parentId: String) -> String {
        let query: String = "SELECT * FROM \(activityName()) WHERE parent_id=\"\(parentId)\""
        return query
    }
    
    func getInsertQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (id, parent_id, data, status, uts) VALUES (:id, :parent_id, :data, :status, :uts)"
    }
    
    func getDeleteQueryForId(_ id: String) -> String{
        return "DELETE FROM \(activityName()) WHERE id=\"\(id)\""
    }
    
    fileprivate func getDeleteQueryForIds(_ ids: Array<String>) -> String{
        return "DELETE FROM \(activityName()) WHERE id IN (\(ids.joined(separator: ",")))"
    }
    
    //MARK: - dictionary
    func getInsertQueryParam(_ params: OstBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = [OstBaseDbQueries.ID: params.id,
                                           OstBaseDbQueries.PARENT_ID: params.parnetId ?? "",
                                           OstBaseDbQueries.DATA: params.data.toData(),
                                           OstBaseDbQueries.UTS: params.updated_timestamp,
                                           OstBaseDbQueries.STATUS: params.status ?? ""
        ]
        return queryParams
    }
    
    func getDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
        var resultData: Array<[String: Any]> = []
        
        while resultSet.next() {
            let decodedData: [String: Any] = (Data(resultSet.data(forColumn: "data")!)).toDictionary()
            resultData.append(decodedData)
        }
        return resultData
    }
}
