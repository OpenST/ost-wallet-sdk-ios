/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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
