//
//  OSTMultiSigWalletRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigWalletRepository: OSTBaseCacheModelRepository, OSTMultiSigWalletModel {
    
    static let sharedMultiSigWallet = OSTMultiSigWalletRepository()
    private override init() {
        print("\n**************\ninit for 'OSTEconomyRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTMultiSigWallet? {
        return try super.get(id) as? OSTMultiSigWallet
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTMultiSigWallet?] {
        return super.getAll(ids) as! [String : OSTMultiSigWallet?]
    }
    
    override func save(_ multiSigWalletData: [String : Any], success: ((OSTMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.save(multiSigWalletData, success: success as? ((OSTBaseEntity?) -> Void), failure: failure)
    }
    
    func saveAll(_ multiSigWalletDataArray: Array<[String : Any]>, success: ((Array<OSTMultiSigWallet>?, Array<OSTMultiSigWallet>?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.saveAll(multiSigWalletDataArray, success: success as? ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void), failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTMultiSigWalletDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTTokenHolder {
        return try OSTTokenHolder(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTMultiSigWalletDbQueries().save(entity as! OSTMultiSigWallet)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTMultiSigWalletDbQueries().saveAll(entities as! Array<OSTMultiSigWallet>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
