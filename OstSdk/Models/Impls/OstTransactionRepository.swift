//
//  OstTransactionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTransactionRepository: OstBaseModelCacheRepository {
    static let sharedTransaction = OstTransactionRepository()
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstBaseDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTransactionDbQueries()
    }
    
    /// Get OstTransaction entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstTransaction object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstTransaction {
        return try OstTransaction(data as [String : Any])
    }
}
