//
//  OstTokenHolderRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderRepository: OstBaseModelCacheRepository{
    // TODO: change this to sharedInstance.
    static let sharedTokenHolder = OstTokenHolderRepository()
    
    // TODO: remove this.
    private override init() {
        Logger.log(message:"\n**************\ninit for 'OstTokenHolderRepository' called\n**************\n")
    }
    
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
