//
//  OstUserModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstUserModelRepository: OstBaseModelCacheRepository {

    static let sharedUser = OstUserModelRepository()
    private override init() {
        print("\n**************\ninit for 'OstUserModelRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstUserDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstUser {
        return try OstUser(data as [String: Any])
    }
}
