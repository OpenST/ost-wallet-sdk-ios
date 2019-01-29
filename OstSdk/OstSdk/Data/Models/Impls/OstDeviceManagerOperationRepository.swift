//
//  OstDeviceManagerOperationRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDeviceManagerOperationRepository: OstBaseModelCacheRepository {
    
    static let sharedDeviceManagerOperation = OstDeviceManagerOperationRepository()
    private override init() {
        print("\n**************\ninit for 'OstDeviceManagerOperationRepository' called\n**************\n")
    }
    
   
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstDeviceManagerOperationDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String : Any])
    }
    

}
