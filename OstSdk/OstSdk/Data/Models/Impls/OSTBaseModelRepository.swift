//
//  OSTBaseModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

enum OSTError: Error {
    case invalidInput(String)
    case actionFailed(String)
}

class OSTBaseModelRepository {
    
    internal static let DBQUEUE = DispatchQueue.main
    
    //MARK: - override
    //************************************* Methods to override *************************************
    
    func getDBQueriesObj() -> OSTBaseDbQueries {
        fatalError("getDBQueriesObj is not override")
    }
    
    func getEntity(_ data: [String : Any]) throws -> OSTBaseEntity {
        fatalError("getEntity is not override")
    }
    
    func saveEntity(_ entity: OSTBaseEntity) -> Bool{
        fatalError("saveEntity is not override")
    }
    
    func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?){
        fatalError("saveAllEntities is not override")
    }
    
    //************************************ Methods to override end ***********************************
    
    //MARK: - prtocol methods
    
    func get(_ id:  String) throws -> OSTBaseEntity? {
        if (!id.isAlphanumeric) {throw OSTError.invalidInput("id should be not null Int/String")}
        if let data: [String : Any] = fetchDataForId(id) {
            do {
                let entityData = try (getEntity(data))
                return entityData
            }catch let error {
                throw error
            }
        }
        return nil
    }
    
    func getAll(_ ids: Array<String>) -> [String: OSTBaseEntity?] {
        var validIds: Array<String> = []
        var invalidIds: [String : OSTBaseEntity?] = [:]
        for id in ids {
            if (id.isAlphanumeric) {
                validIds.append(id)
            }else {
                invalidIds[id] = nil
            }
        }
        return bulkFetchDataForId(validIds)
    }
    
    func delete(_ id: String, success: ((Bool)->Void)?) {
        if (!id.isAlphanumeric) {success?(false)}
        
        OSTBaseModelRepository.DBQUEUE.async {
            let isSuccess = self.getDBQueriesObj().deleteForId(id)
            success?(isSuccess)
        }
    }
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?){
        OSTBaseModelRepository.DBQUEUE.async {
            var validIds: Array<String> = []
            for id in ids {
                if (id.isAlphanumeric) { validIds.append(id) }
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
    
    
    func bulkFetchDataForId(_ ids: Array<String>) -> [String: OSTBaseEntity?] {
        let data: [String: [String: Any]?]? = getDBQueriesObj().selectForIds(ids)
        var entities: [String: OSTBaseEntity?] = [:]
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
    
    func insertOrUpdate(_ entityObj: OSTBaseEntity) -> OSTBaseEntity? {
        
        let isInsertionSuccess = saveEntity(entityObj)
        return isInsertionSuccess ? entityObj : nil
    }
    
    func bulkInsertOrUpdate(_ entityArray: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) {

            let (successArray, failuarArray) = saveAllEntities(entityArray)
            return (successArray ?? nil, failuarArray ?? nil)
    }
    
    func save(_ data: [String : Any], success: ((OSTBaseEntity?) -> Void)?, failure: ((Error) -> Void)?) {
        OSTBaseModelRepository.DBQUEUE.async {
            do {
                let entityObj = try self.getEntity(data)
                let entity: OSTBaseEntity? = self.insertOrUpdate(entityObj)
                (entity != nil) ? success?(entity!) : failure?(OSTError.actionFailed("Insertion of UserData failed."))
            }catch let error {
                failure?(error)
            }
        }
    }
    
    func saveAll(_ dataArray: Array<[String: Any]>, success: ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void)?, failure: ((Error) -> Void)?) {
        OSTBaseModelRepository.DBQUEUE.async {
            do {
                var entities: Array<OSTBaseEntity> = []
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
