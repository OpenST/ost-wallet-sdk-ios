//
//  OstMultiSigWalletDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigWalletDbQueries: OstBaseDbQueries {
    
    func save(_ entity: OstMultiSigWallet) -> Bool {
        return insertOrUpdateInDB(params: entity as OstBaseEntity)
    }
    
    func saveAll(_ entities: Array<OstMultiSigWallet>) -> (Array<OstMultiSigWallet>?, Array<OstMultiSigWallet>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OstBaseEntity>))
        return ((successArray as? Array<OstMultiSigWallet>) ?? nil , (failuarArray as? Array<OstMultiSigWallet>) ?? nil)
    }
    
    override func activityName() -> String{
        return "multi_sig_wallets"
    }
}
