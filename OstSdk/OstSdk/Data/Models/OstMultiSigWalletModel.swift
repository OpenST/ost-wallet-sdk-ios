//
//  OstMultiSigWalletModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstMultiSigWalletModel: class {
    
    func get(_ id:  String) throws -> OstMultiSigWallet?
    
    func getAll(_ ids:  Array<String>) -> [String: OstMultiSigWallet?]
    
    func save(_ multiSigWalletData: [String : Any], success: ((OstMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ multiSigWalletDataArray: Array<[String: Any]>, success: ((Array<OstMultiSigWallet>?, Array<OstMultiSigWallet>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
