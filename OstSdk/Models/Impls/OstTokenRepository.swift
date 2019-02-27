//
//  OstTokenRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenRepository: OstBaseModelCacheRepository {
    // TODO: change this to sharedInstance.
    static let sharedToken = OstTokenRepository()
    
    // TODO: remove this.
    private override init() {
        Logger.log(message:"\n**************\ninit for 'OstTokenRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstBaseDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenDbQueries()
    }
    
    /// Get OstToken entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstToken object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstToken {
        return try OstToken(data as [String : Any])
    }
    
    
}
