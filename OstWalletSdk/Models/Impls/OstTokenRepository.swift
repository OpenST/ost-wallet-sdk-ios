/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstTokenRepository: OstBaseModelCacheRepository {
    static let sharedToken = OstTokenRepository()
    
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
