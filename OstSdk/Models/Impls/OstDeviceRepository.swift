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
    private override init() {
        print("\n**************\ninit for 'OstDeviceRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstDeviceDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstDevice {
        return try OstDevice(data as [String : Any])
    }
}
