//
//  OstTokenHolderSessionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderSessionRepository: OstBaseModelCacheRepository {
    
    static let sharedTokenHolderSession = OstTokenHolderSessionRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenHolderSessionRepository' called\n**************\n")
    }
    
   
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenHolderSessionDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String: Any])
    }
    
   
}
