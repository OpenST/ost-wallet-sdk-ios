/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstUserModelRepository: OstBaseModelCacheRepository {
    static let sharedUser = OstUserModelRepository()
    
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
