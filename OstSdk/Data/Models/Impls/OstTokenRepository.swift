//
//  OstTokenRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenRepository: OstBaseModelCacheRepository {
    
    static let sharedToken = OstTokenRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenRepository' called\n**************\n")
    }
    
   
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstToken {
        return try OstToken(data as [String : Any])
    }
    
    
}
