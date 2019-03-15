/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDeviceManagerRepository: OstBaseModelCacheRepository {
    static let sharedDeviceManager = OstDeviceManagerRepository()

    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstBaseDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstDeviceManagerDbQueries()
    }
    
    /// Get OstDeviceManager entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstDeviceManager object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstDeviceManager {
        return try OstDeviceManager(data as [String : Any])
    }
}
