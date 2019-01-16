//
//  OstBaseModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

enum OstError: Error {
    case invalidInput(String)
    case actionFailed(String)
}

class OstBaseModelRepository {
    
    internal static let DBQUEUE = DispatchQueue.main
    
    //MARK: - override
    //************************************* Methods to override *************************************
    
    func getDBQueriesObj() -> OstBaseDbQueries {
        fatalError("getDBQueriesObj is not override")
    }
    
    func getEntity(_ data: [String : Any]) throws -> OstBaseEntity {
        fatalError("getEntity is not override")
    }
    
    func saveEntity(_ entity: OstBaseEntity) -> Bool{
        fatalError("saveEntity is not override")
    }
    
    func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?){
        fatalError("saveAllEntities is not override")
    }
    
    //************************************ Methods to override end ***********************************
    
    //MARK: - prtocol methods
    
    func get(_ id:  String) throws -> OstBaseEntity? {
        if (!id.isUUID) {throw OstError.invalidInput("id should be not null Int/String")}
        if let data: [String : Any] = fetchDataForId(id) {
            do {
                let entityData = try getEntity(data)
                return entityData
            }catch let error {
                throw error
            }
        }
        return nil
    }
    
    func getByParent(_ parent_id: String) throws -> [OstBaseEntity]? {
        guard let result: Array<[String: Any]> = getDBQueriesObj().selectByParentId(parent_id) else {
            return nil
        }
        var entities: Array<OstBaseEntity> = []
        for ele in result {
            do {
                let entityData = try getEntity(ele)
                entities.append(entityData)
            }catch let error{
                throw error
            }
            return entities
        }
        return nil
    }
    
    func getAll(_ ids: Array<String>) -> [String: OstBaseEntity?] {
        var validIds: Array<String> = []
        var invalidIds: [String : OstBaseEntity?] = [:]
        for id in ids {
            if (id.isUUID) {
                validIds.append(id)
            }else {
                invalidIds[id] = nil
            }
        }
        return bulkFetchDataForId(validIds)
    }
    
    func delete(_ id: String, success: ((Bool)->Void)?) {
        if (!id.isUUID) {success?(false)}
        
        OstBaseModelRepository.DBQUEUE.async {
            let isSuccess = self.getDBQueriesObj().deleteForId(id)
            success?(isSuccess)
        }
    }
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?){
        OstBaseModelRepository.DBQUEUE.async {
            var validIds: Array<String> = []
            for id in ids {
                if (id.isUUID) { validIds.append(id) }
            }
            let isSuccess = self.getDBQueriesObj().bulkDeleteForIds(ids)
            success?(isSuccess)
        }
    }
    
    //MARK: - base methods
    
    func fetchDataForId(_ id: String) -> [String: Any]? {
        if let data: [String: Any] = getDBQueriesObj().selectForId(id) {
            return data
        }
        return nil
    }
    
    
    func bulkFetchDataForId(_ ids: Array<String>) -> [String: OstBaseEntity?] {
        let data: [String: [String: Any]?]? = getDBQueriesObj().selectForIds(ids)
        var entities: [String: OstBaseEntity?] = [:]
        for id in ids {
            let entityData: [String: Any]? = data?[id] as? [String: Any] ?? nil
            do {
                entities[id] = (entityData != nil) ? try getEntity(entityData!) : nil
            }catch {
                entities[id] = nil
            }
            
        }
        return entities
    }
    
    func insertOrUpdate(_ entityObj: OstBaseEntity) -> OstBaseEntity? {
        
        let isInsertionSuccess = saveEntity(entityObj)
        return isInsertionSuccess ? entityObj : nil
    }
    
    func bulkInsertOrUpdate(_ entityArray: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?, Array<OstBaseEntity>?) {

            let (successArray, failuarArray) = saveAllEntities(entityArray)
            return (successArray ?? nil, failuarArray ?? nil)
    }
    
    func save(_ data: [String : Any], success: ((OstBaseEntity?) -> Void)?, failure: ((Error) -> Void)?) {
        OstBaseModelRepository.DBQUEUE.async {
            do {
                let entityObj = try self.getEntity(data)
                let entity: OstBaseEntity? = self.insertOrUpdate(entityObj)
                (entity != nil) ? success?(entity!) : failure?(OstError.actionFailed("Insertion of entity failed."))
            }catch let error {
                failure?(error)
            }
        }
    }
    
    func saveAll(_ dataArray: Array<[String: Any]>, success: ((Array<OstBaseEntity>?, Array<OstBaseEntity>?) -> Void)?, failure: ((Error) -> Void)?) {
        OstBaseModelRepository.DBQUEUE.async {
            do {
                var entities: Array<OstBaseEntity> = []
                for data in dataArray {
                    let entityObj = try self.getEntity(data)
                    entities.append(entityObj)
                }
                let (successArray, failuarArray) = self.bulkInsertOrUpdate(entities)
                success?(successArray ?? nil, failuarArray ?? nil)
            }catch let error { failure?(error) }
        }
    }
}
