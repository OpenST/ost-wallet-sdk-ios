//
//  OstMultiSigWalletRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigWalletRepository: OstBaseCacheModelRepository, OstMultiSigWalletModel {
    
    static let sharedMultiSigWallet = OstMultiSigWalletRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigWalletRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstMultiSigWallet? {
        return try super.get(id) as? OstMultiSigWallet
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstMultiSigWallet?] {
        return super.getAll(ids) as! [String : OstMultiSigWallet?]
    }
    
    override func save(_ multiSigWalletData: [String : Any], success: ((OstMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(multiSigWalletData, success: { (entity) in
            success?(entity as? OstMultiSigWallet)
        }, failure: failure)
    }
    
    func saveAll(_ multiSigWalletDataArray: Array<[String : Any]>, success: ((Array<OstMultiSigWallet>?, Array<OstMultiSigWallet>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(multiSigWalletDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstMultiSigWallet>, failuarEntityArray as? Array<OstMultiSigWallet>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigWalletDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstMultiSigWallet {
        return try OstMultiSigWallet(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstMultiSigWalletDbQueries().save(entity as! OstMultiSigWallet)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstMultiSigWalletDbQueries().saveAll(entities as! Array<OstMultiSigWallet>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
