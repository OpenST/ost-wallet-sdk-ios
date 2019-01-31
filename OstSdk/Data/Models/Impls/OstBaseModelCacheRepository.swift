//
//  OstBaseModelCacheRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstBaseModelCacheRepository: OstBaseModelRepository {
    
    private var entityCache: NSCache<NSString, OstBaseEntity>?
    
    override init() {
        super.init()
        entityCache = NSCache<NSString, OstBaseEntity>()
        entityCache!.countLimit = maxCountToCache()
    }
    
    func maxCountToCache() -> Int {
        return 5
    }
    
    override func getById(_ id: String) throws -> OstBaseEntity? {
        if let entity = getEntityFromCache(forKey: id) {
            print("got entity from cache")
            return entity
        }
        
        if let entity = try super.getById(id) {
            saveEntityInCache(key: entity.id, entity: entity)
            return entity
        }
        
        return nil
    }
    
    override func getByParentId(_ parent_id: String) throws -> [OstBaseEntity]? {
        if let entity = getEntityFromCache(forKey: parent_id) {
            return [entity]
        }
        
        if let entityArray = try super.getByParentId(parent_id) {
            return entityArray
        }
        return nil
    }
    
    override func insertOrUpdateEntity(_ entity: OstBaseEntity) -> OstBaseEntity? {
        saveEntityInCache(key: entity.id, entity: entity)
        return super.insertOrUpdateEntity(entity)
    }
    
    func deleteForId(_ id: String) {
        super.deleteForId(id, callback: nil)
        self.removeFromCache(key: id)
    }
    
    // MARK: - In cache
   
    fileprivate func getEntityFromCache(forKey key: String) -> OstBaseEntity? {
        
        if let cacheData = entityCache!.object(forKey: key as NSString) {
            return cacheData
        }
        return nil
    }
    
    fileprivate func saveEntityInCache(key: String, entity: OstBaseEntity) {
        
        if let cacheData = getEntityFromCache(forKey: key) {
            cacheData.data = entity.data
        }else {
            entityCache!.setObject(entity, forKey: key as NSString)
        }
        
    }
    
    fileprivate func removeFromCache(key: String) {
        entityCache!.removeObject(forKey: key as NSString)
    }
}
