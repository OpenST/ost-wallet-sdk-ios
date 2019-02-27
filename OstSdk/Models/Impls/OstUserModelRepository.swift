//
//  OstUserModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstUserModelRepository: OstBaseModelCacheRepository {
    // TODO: change this to sharedInstance.
    static let sharedUser = OstUserModelRepository()
    
    // TODO: remove this.
    private override init() {
        Logger.log(message:"\n**************\ninit for 'OstUserModelRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstUserDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstUserDbQueries()
    }
    
    /// Get OstUser entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstUser object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstUser {
        return try OstUser(data as [String: Any])
    }
}
