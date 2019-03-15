/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstSessionRepository: OstBaseModelCacheRepository {
    static let sharedSession = OstSessionRepository()
       
    func getActiveSessionsFor(parentId: String) throws -> [OstSession]? {
        let dbQueryObj = getDBQueriesObj() as! OstSessionDbQueries
        
        if let dbEntityDataArray: [[String: Any?]] = try dbQueryObj.getActiveSessionsFor(parentId) {
            var entities: Array<OstSession> = []
            for dbEntityData in dbEntityDataArray {
                let entityData = try getEntity(dbEntityData as [String : Any])
                entities.append(entityData)
            }
            return entities
        }
        return nil
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstSessionDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstSession {
        return try OstSession(data as [String: Any])
    }
    
   
}
