//
//  OstMultiSigR.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigRepository: OstBaseModelCacheRepository {
    static let sharedMultiSig = OstMultiSigRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigRepository' called\n**************\n")
    }
    
    
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstMultiSig {
        return try OstMultiSig(data as [String : Any])
    }
    
   
}
