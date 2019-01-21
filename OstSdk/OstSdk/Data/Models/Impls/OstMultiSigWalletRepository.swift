//
//  OstMultiSigWalletRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigWalletRepository: OstBaseModelCacheRepository {
    
    static let sharedMultiSigWallet = OstMultiSigWalletRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigWalletRepository' called\n**************\n")
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigWalletDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstMultiSigWallet {
        return try OstMultiSigWallet(data as [String : Any])
    }
}
