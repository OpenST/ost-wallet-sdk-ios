//
//  OstDeviceRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDeviceRepository: OstBaseModelCacheRepository {
    static let sharedDevice = OstDeviceRepository()
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstBaseDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstDeviceDbQueries()
    }
    
    /// Get OstDevice entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstDevice object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstDevice {
        return try OstDevice(data as [String : Any])
    }
}
