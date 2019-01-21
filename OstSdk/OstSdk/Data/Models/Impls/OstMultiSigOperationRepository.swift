//
//  OstMultiSigOperationRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigOperationRepository: OstBaseModelCacheRepository {
    
    static let sharedMultiSigOperation = OstMultiSigOperationRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigOperationRepository' called\n**************\n")
    }
    
   
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigOperationDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstTokenHolder {
        return try OstTokenHolder(data as [String : Any])
    }
    

}
