/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstBaseModelCacheRepository: OstBaseModelRepository {
    /// Max entity cache count
    private static let MAX_CACHE_COUNT = 5
    
    /// Cache object
    private var entityCache: NSCache<NSString, OstBaseEntity>?
    
    /// Initializer
    override init() {
        super.init()
        entityCache = NSCache<NSString, OstBaseEntity>()
        entityCache!.countLimit = maxCountToCache()
    }
    
    /// Maximum number of items to be cached
    ///
    /// - Returns: Count
    func maxCountToCache() -> Int {
        return OstBaseModelCacheRepository.MAX_CACHE_COUNT
    }
    
    /// Get Item by id
    ///
    /// - Parameter id: Key identifier
    /// - Returns: OStBaseEntity object
    /// - Throws: OSTError
    override func getById(_ id: String) throws -> OstBaseEntity? {
        // Check if the item is avaialable in cache.
        if let entity = getEntityFromCache(forKey: id) {
            return entity
        }
        // Get entity from db
        if let entity = try super.getById(id) {
            // Save the entity in cache
            self.saveEntityInCache(key: entity.id, entity: entity)
            return entity
        }        
        return nil
    }
    
    /// Insert or update entity. Save the entity in cache
    ///
    /// - Parameter entity: Entity object
    ///   - isSynchronous: Indicated if its a synchronous task
    /// - Returns: Entity object
    override func insertOrUpdateEntity(_ entity: OstBaseEntity, _ isSynchronous:Bool = false) {
        self.saveEntityInCache(key: entity.id, entity: entity)
        return super.insertOrUpdateEntity(entity, isSynchronous)
    }
    
    /// Delete item for given identifier key
    ///
    /// - Parameter id: Key identifier
    func deleteForId(_ id: String) {
        self.removeFromCache(key: id)
        super.deleteForId(id, callback: nil)
    }
    
    // MARK: - In cache
   
    /// Get entity from cache for the given key identifier
    ///
    /// - Parameter key: Key identifier
    /// - Returns: OstBaseEntity object
    fileprivate func getEntityFromCache(forKey key: String) -> OstBaseEntity? {
        if let cacheData = entityCache!.object(forKey: key.lowercased() as NSString) {
            return cacheData
        }
        return nil
    }
    
    /// Save the entity object in cache
    ///
    /// - Parameters:
    ///   - key: Key identifier
    ///   - entity: Entity object
    fileprivate func saveEntityInCache(key: String, entity: OstBaseEntity) {
        if let cacheData = getEntityFromCache(forKey: key) {
            try! cacheData.updateEntityData(entity.data)
        }else {
            entityCache!.setObject(entity, forKey: key.lowercased() as NSString)
        }
    }
    
    /// Remove entity from cache
    ///
    /// - Parameter key: Key identifier
    fileprivate func removeFromCache(key: String) {
        entityCache!.removeObject(forKey: key as NSString)
    }
}
