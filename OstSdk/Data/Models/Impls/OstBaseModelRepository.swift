//
//  OstBaseModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstBaseModelRepository {
    
    internal static let DBQUEUE = DispatchQueue.init(label: "dbQueue")
    private var inMemoryCache: [String: OstBaseEntity] = [:]
    
    class func getId(_ entityData: [String: Any?], forKey key: String) throws -> String {
        guard let identifer = entityData[key] else {
            throw OstError.invalidInput("JsonOject doesn't have desired identifier")
        }
        return identifer as! String
    }
    
    class func getUpdatedTimestamp(_ entityData: [String: Any?]) -> Int {
        return OstUtils.toInt(entityData[OstBaseEntity.UPDATED_TIMESTAMP] as Any?) ?? 0
        
    }
    
    final func insertOrUpdate(_ entityData: [String: Any?], forIdentifierKey identifier: String) throws -> OstBaseEntity? {
        let id: String = try OstBaseModelRepository.getId(entityData, forKey: identifier)
        if let dbEntity = try getById(id) {
            let updatedTmestamp = OstBaseModelRepository.getUpdatedTimestamp(entityData)
            if (updatedTmestamp == dbEntity.updated_timestamp) {
                return dbEntity
            }
            dbEntity.processJson(entityData)
            return insertOrUpdateEntity(dbEntity)
        }
        let entity = try getEntity(entityData)
        return insertOrUpdateEntity(entity)
    }
    
    
    //MARK: - override
//************************************* Methods to override *************************************
    func getDBQueriesObj() -> OstBaseDbQueries {
        fatalError("getDBQueriesObj is not override")
    }
    
    func getEntity(_ data: [String : Any?]) throws -> OstBaseEntity {
        fatalError("getEntity is not override")
    }
//************************************ Methods to override end ***********************************
    
    func getById(_ id: String) throws -> OstBaseEntity? {
        if let entity = getEntityFromInMemory(ForId: id) {
            return entity
        }
        
        let dbQueryObj = getDBQueriesObj()
        if let dbEntityData: [String: Any?] = try dbQueryObj.getById(id) {
            let entityData = try getEntity(dbEntityData as [String : Any])
            return entityData
        }
        return nil
    }
    
    func getByParentId(_ parentId: String) throws -> [OstBaseEntity]? {
        let dbQueryObj = getDBQueriesObj()
        if let dbEntityDataArray: [[String: Any?]] = try dbQueryObj.getByParentId(parentId) {
            var entities: Array<OstBaseEntity> = []
            for dbEntityData in dbEntityDataArray {
                let entityData = try getEntity(dbEntityData as [String : Any])
                entities.append(entityData)
            }
            return entities
        }
        return nil
    }
    
    func insertOrUpdateEntity(_ entity: OstBaseEntity) -> OstBaseEntity? {
        saveEntityInMemory(key: entity.id, val: entity)
        OstBaseModelRepository.DBQUEUE.async {
            let dbQueryObj = self.getDBQueriesObj()
            let isSuccess = dbQueryObj.insertOrUpdate(entity)
            if isSuccess {
                self.removeInMemoryEntity(key: entity.id)
            }
        }
        return entity
    }
    
    func deleteForId(_ id: String, callback: ((Bool)->Void)?) {
        removeInMemoryEntity(key: id)
        OstBaseModelRepository.DBQUEUE.async {
            let dbQueryObj = self.getDBQueriesObj()
            let isSuccess = dbQueryObj.deleteForId(id)
            callback?(isSuccess)
        }
    }
    
    //MARK: - In memory
    fileprivate func getEntityFromInMemory(ForId id: String) -> OstBaseEntity? {
        if let inMemoryData = inMemoryCache[id] {
            return inMemoryData
        }
        return nil
    }
    
    fileprivate func saveEntityInMemory(key: String, val: OstBaseEntity) {
        if (inMemoryCache[key] == nil) {
            inMemoryCache[key] = val
        }else {
            let inMemoryVal: OstBaseEntity = (inMemoryCache[key])!
            inMemoryVal.data = val.data
        }
    }
    
    fileprivate func removeInMemoryEntity(key: String) {
        inMemoryCache[key] = nil
    }

}

