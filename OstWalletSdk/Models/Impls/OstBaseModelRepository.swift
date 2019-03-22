/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstBaseModelRepository {
    /// Dispatch queue
    internal static let DBQUEUE = DispatchQueue.init(label: "dbQueue")
    
    /// Data stored in memory
    private var inMemoryCache: [String: OstBaseEntity] = [:]
    
    /// Get item from the entity data for the given key
    ///
    /// - Parameters:
    ///   - entityData: Entity data dictionary
    ///   - key: Key identifier
    /// - Returns: String value of the item
    /// - Throws: OSTError
    class func getItem(fromEntityData entityData: [String: Any?], forKey key: String) throws -> String {
        guard let identifer = entityData[key] else {
            throw OstError.init("m_i_bmr_gi_1", .invalidJsonObjectIdentifier)
        }
        return OstUtils.toString(identifer as Any?)!
    }
    
    /// Get update timestamp
    ///
    /// - Parameter entityData: Entity data
    /// - Returns: TimeInterval
    class func getUpdatedTimestamp(_ entityData: [String: Any?]) -> TimeInterval {
        guard let timestamp: String = OstUtils.toString(entityData[OstBaseEntity.UPDATED_TIMESTAMP] as Any?) else {
            return 0
        }
        return TimeInterval(timestamp) ?? 0
    }
    
    /// Insert or update the entity data for the provided identifer key
    ///
    /// - Parameters:
    ///   - entityData: Entity data
    ///   - identifier: Identifier key
    ///   - isSynchronous: Indicated if its a synchronous task
    /// - Returns: OstBaseEntity object
    /// - Throws: OSTError
    final func insertOrUpdate(_ entityData: [String: Any?],
                              forIdentifierKey identifier: String,
                              isSynchronous: Bool = false) throws {
        // Commenting the below code. The entities will always be written in DB
        
        //        // Get the primary id value of the entity
        //        let id: String = try OstBaseModelRepository.getItem(fromEntityData: entityData, forKey: identifier)
        //
        //        // Check if the entity already exists
        //        if let dbEntity = try getById(id) {
        //            let updatedTimestamp = OstBaseModelRepository.getUpdatedTimestamp(entityData)
        //            // Check if the entity is already updated or not, if updated nothing is to be done.
        //            if (updatedTimestamp == dbEntity.updatedTimestamp) {
        //                return
        //            }
        //        }
        
        // Create a new entity object and update the db
        let entity = try getEntity(entityData)
        insertOrUpdateEntity(entity, isSynchronous)
    }
    
    /// Get entity object for the given id value
    ///
    /// - Parameter id: Id string
    /// - Returns: OstBaseEntity object
    /// - Throws: OSTError
    func getById(_ id: String) throws -> OstBaseEntity? {
        // Check if the entity is available in the memory cache, if availalbe its safe to return the object
        if let entity = getEntityFromInMemory(ForId: id) {
            return entity
        }
        
        // Get the db query.
        let dbQueryObj = getDBQueriesObj()
        // Get the entity data from the database.
        if let dbEntityData: [String: Any?] = try dbQueryObj.getById(id) {
            // Create the entity object from the entity data.
            let entityData = try getEntity(dbEntityData as [String : Any])
            return entityData
        }
        return nil
    }
    
    /// Get entity objects for given parent id
    ///
    /// - Parameter parentId: Parent identifier
    /// - Returns: Array<OstBaseEntity>, array containing entity objects
    /// - Throws: OSTError
    func getByParentId(_ parentId: String) throws -> [OstBaseEntity]? {
        // Get the db query.
        let dbQueryObj = getDBQueriesObj()
        if let dbEntityDataArray: [[String: Any?]] = try dbQueryObj.getByParentId(parentId) {
            var entities: Array<OstBaseEntity> = []
            for dbEntityData in dbEntityDataArray {
                // Create the entity object from the entity data.
                let entityData = try getEntity(dbEntityData as [String : Any])
                entities.append(entityData)
            }
            return entities
        }
        return nil
    }
    
    /// Insert or update entity
    ///
    /// - Parameter entity: Entity object
    ///   - isSynchronous: Indicated if its a synchronous task
    /// - Returns: Entity object
    func insertOrUpdateEntity(_ entity: OstBaseEntity, _ isSynchronous:Bool = false) {
        // Save the entity object in mememory cache.
        saveEntityInMemory(key: entity.id, val: entity)
        
        func perform() {
            let dbQueryObj = self.getDBQueriesObj()
            dbQueryObj.insertOrUpdate(entity, onUpdate: {(result:Bool) in
                if (result == true) {
                    self.removeInMemoryEntity(key: entity.id)
                }
            })
        }
        
        if isSynchronous {
            OstBaseModelRepository.DBQUEUE.sync {
                perform()
            }
        } else {
            OstBaseModelRepository.DBQUEUE.async {
                perform()
            }
        }
        
    }
    
    /// Delete item for the give key identifier
    ///
    /// - Parameters:
    ///   - id: Key identifier
    ///   - callback: Call back indication the success or failure
    func deleteForId(_ id: String, callback: ((Bool)->Void)?) {
        removeInMemoryEntity(key: id)
        OstBaseModelRepository.DBQUEUE.async {
            let dbQueryObj = self.getDBQueriesObj()
            let isSuccess = dbQueryObj.deleteForId(id)
            callback?(isSuccess)
        }
    }
    
    //MARK: - In memory
    
    /// Get entity from memory cache
    ///
    /// - Parameter id: Key identifier
    /// - Returns: OstBaseEntity object
    fileprivate func getEntityFromInMemory(ForId id: String) -> OstBaseEntity? {
        if let inMemoryData = inMemoryCache[id.lowercased()] {
            return inMemoryData
        }
        return nil
    }
    
    /// Save entity in memory cache
    ///
    /// - Parameters:
    ///   - key: Key identifier
    ///   - val: Entity object
    fileprivate func saveEntityInMemory(key: String, val: OstBaseEntity) {
        if (inMemoryCache[key] == nil) {
            inMemoryCache[key.lowercased()] = val
        }else {
            let inMemoryVal: OstBaseEntity = (inMemoryCache[key])!
            try! inMemoryVal.updateEntityData(val.data)
        }
    }
    
    /// Remove entity from memory cache
    ///
    /// - Parameter key: Key identifier
    fileprivate func removeInMemoryEntity(key: String) {
        inMemoryCache[key] = nil
    }

    //MARK: - Override methods
    
    /// Get the DBQueries object. This has to be overridden by the inherited classes.
    /// This should never be called.
    func getDBQueriesObj() -> OstBaseDbQueries {
        fatalError("getDBQueriesObj is not override")
    }
    
    /// Get the Entity object. This has to be overridden by the inherited classes.
    /// This should never be called.
    func getEntity(_ data: [String : Any?]) throws -> OstBaseEntity {
        fatalError("getEntity is not override")
    }
}
