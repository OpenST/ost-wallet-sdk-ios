//
//  OstCreditRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstCreditRepository: OstBaseModelCacheRepository {
    
    static let sharedCredit = OstCreditRepository()
    private override init() {
        print("\n**************\ninit for 'OstCreditRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstCreditDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstCredit {
        return try OstCredit(data as [String : Any])
    }
}
