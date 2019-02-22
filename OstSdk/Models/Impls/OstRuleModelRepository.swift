//
//  OstRoleModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstRuleModelRepository: OstBaseModelCacheRepository{
    
    static let sharedRule = OstRuleModelRepository()
    private override init() {
        print("\n**************\ninit for 'OstRuleModelRepository' called\n**************\n")
    }
    
   
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstRule {
        return try OstRule(data as [String : Any])
    }
}
