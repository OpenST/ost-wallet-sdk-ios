//
//  OstExecutableRuleRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstExecutableRuleRepository: OstBaseModelCacheRepository {
    
    static let sharedExecutableRule = OstExecutableRuleRepository()
    private override init() {
        print("\n**************\ninit for 'OstExecutableRuleRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstExecutableRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String : Any])
    }
}
