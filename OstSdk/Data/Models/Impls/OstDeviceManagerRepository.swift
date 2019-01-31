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
    
    private override init() {
        print("\n**************\ninit for 'OstDeviceManagerRepository' called\n**************\n")
    }
    
    
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstDeviceManagerDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstDeviceManager {
        return try OstDeviceManager(data as [String : Any])
    }
    
   
}
