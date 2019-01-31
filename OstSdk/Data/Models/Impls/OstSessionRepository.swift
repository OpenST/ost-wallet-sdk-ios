//
//  OstSessionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSessionRepository: OstBaseModelCacheRepository {
    
    static let sharedSession = OstSessionRepository()
    private override init() {
        print("\n**************\ninit for 'OstSessionRepository' called\n**************\n")
    }
    
   
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstSessionDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstSession {
        return try OstSession(data as [String: Any])
    }
    
   
}
