//
//  OstSessionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSessionRepository: OstBaseModelCacheRepository {
    // TODO: change this to sharedInstance.
    static let sharedSession = OstSessionRepository()
    
    // TODO: remove this.
    private override init() {
        Logger.log(message:"\n**************\ninit for 'OstSessionRepository' called\n**************\n")
    }
    
   
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
