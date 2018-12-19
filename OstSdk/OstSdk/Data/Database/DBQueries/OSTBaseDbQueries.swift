//
//  BaseDbQuery.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTBaseDbQueries: OSTDBQueriesProtocol {
    
    static let ID = "id"
    static let PARENT_ID = "parent_id"
    static let DATA = "data"
    static let STATUS = "status"
    static let UTS = "uts"
    
    static let queue = DispatchQueue(label: "db", qos: .background, attributes: .concurrent)
    fileprivate weak var db: FMDatabase?
    init() {
        db = OSTSdkDatabase.sharedInstance.database
        db?.open()
    }
    deinit {
        db?.close()
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
    
    func insertOrUpdateInDB(params: OSTBaseEntity) -> Bool {
        let insertQuery = getInsertQuery()
        let queryParam = getInsertQueryParam(params)
        return db?.executeUpdate(insertQuery, withParameterDictionary: queryParam) ?? false
    }
    
    func bulkInsertOrUpdateInDB(params: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>, Array<OSTBaseEntity>) {
        let insertQuery: String = getInsertQuery()
        var insertSuccessArray: Array<OSTBaseEntity> = Array()
        var insertFailuarArray: Array<OSTBaseEntity> = Array()
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
    fileprivate func getSelectQueryById(_ id: String) -> String {
        return "SELECT * FROM \(activityName()) WHERE id=\(id)"
    }
    
    fileprivate func getSelectQueryByIds(_ ids: Array<String>) -> String {
        let query: String = "SELECT * FROM \(activityName()) WHERE id IN (\(ids.joined(separator: ",")))"
        return query
    }
    
    fileprivate func getInsertQuery() -> String {
        return "INSERT OR REPLACE INTO \(activityName()) (id, parent_id, data, status, uts) VALUES (:id, :parent_id, :data, :status, :uts)"
    }
    
    fileprivate func getUpdateQuery() -> String {
        return "UPDATE \(activityName()) SET uts = :uts, data = :data WHERE id = :id;"
    }
    
    fileprivate func getDeleteQueryForId(_ id: String) -> String{
        return "DELETE FROM \(activityName()) WHERE id=\(id)"
    }
    
    fileprivate func getDeleteQueryForIds(_ ids: Array<String>) -> String{
        return "DELETE FROM \(activityName()) WHERE id IN (\(ids.joined(separator: ",")))"
    }
    
    //MARK: - dictionary
    fileprivate func getInsertQueryParam(_ params: OSTBaseEntity) -> [String: Any] {
        let queryParams : [String: Any] = [OSTBaseDbQueries.ID: params.id,
                                           OSTBaseDbQueries.PARENT_ID: params.parnet_id,
                                           OSTBaseDbQueries.DATA: params.data.toData(),
                                           OSTBaseDbQueries.UTS: params.uts,
                                           OSTBaseDbQueries.STATUS: params.baseStatus
        ]
        return queryParams
    }
    
    fileprivate func getDataFromResultSet(_ resultSet: FMResultSet) -> [[String: Any]] {
        var resultData: Array<[String: Any]> = []
        
        while resultSet.next() {
            let dDataVal: [String: Any] = (Data(resultSet.data(forColumn: "data")!)).toDictionary()
            let r: [String: Any] = [OSTBaseDbQueries.ID: resultSet.string(forColumn: OSTBaseDbQueries.ID)!,
                                    OSTBaseDbQueries.PARENT_ID: resultSet.string(forColumn: OSTBaseDbQueries.PARENT_ID)!,
                                    OSTBaseDbQueries.DATA: dDataVal,
                                    OSTBaseDbQueries.STATUS: resultSet.string(forColumn: OSTBaseDbQueries.STATUS)!,
                                    OSTBaseDbQueries.UTS: resultSet.string(forColumn: OSTBaseDbQueries.UTS)!
            ]
            resultData.append(r)
        }
        
        return resultData
    }
}
