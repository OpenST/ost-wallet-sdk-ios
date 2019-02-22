//
//  OstTokenHolderRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderRepository: OstBaseModelCacheRepository{
    static let sharedTokenHolder = OstTokenHolderRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenHolderRepository' called\n**************\n")
    }
    
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenHolderDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String : Any])
    }
}
