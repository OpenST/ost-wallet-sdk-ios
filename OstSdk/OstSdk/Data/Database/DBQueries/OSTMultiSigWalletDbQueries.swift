//
//  OSTMultiSigWalletDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigWalletDbQueries: OSTBaseDbQueries {
    
    func save(_ entity: OSTMultiSigWallet) -> Bool {
        return insertOrUpdateInDB(params: entity as OSTBaseEntity)
    }
    
    func saveAll(_ entities: Array<OSTMultiSigWallet>) -> (Array<OSTMultiSigWallet>?, Array<OSTMultiSigWallet>?) {
        let (successArray, failuarArray) = bulkInsertOrUpdateInDB(params: (entities as Array<OSTBaseEntity>))
        return ((successArray as? Array<OSTMultiSigWallet>) ?? nil , (failuarArray as? Array<OSTMultiSigWallet>) ?? nil)
    }
    
    override func activityName() -> String{
        return "multi_sig_wallets"
    }
}
