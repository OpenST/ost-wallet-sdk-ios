//
//  OstTokenHolderRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderRepository: OstBaseModelCacheRepository{
    static let sharedTokenHolder = OstTokenHolderRepository()
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstBaseDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenHolderDbQueries()
    }
    
    /// Get OstTokenHolder entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstTokenHolder object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String : Any])
    }
}
