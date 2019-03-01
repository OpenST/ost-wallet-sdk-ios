//
//  OstRoleModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstRuleModelRepository: OstBaseModelCacheRepository{
    // TODO: change this to sharedInstance.
    static let sharedRule = OstRuleModelRepository()
    
    // TODO: remove this.
    private override init() {
        Logger.log(message:"\n**************\ninit for 'OstRuleModelRepository' called\n**************\n")
    }

    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstRuleDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstRuleDbQueries()
    }
    
    /// Get OstRule entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstRule object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstRule {
        return try OstRule(data as [String : Any])
    }
}
