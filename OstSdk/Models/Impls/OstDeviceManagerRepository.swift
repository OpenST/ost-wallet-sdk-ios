//
//  OstMultiSigRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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