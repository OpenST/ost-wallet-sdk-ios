//
//  OSTMultiSigWalletModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTMultiSigWalletModel: class {
    
    func get(_ id:  String) throws -> OSTMultiSigWallet?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTMultiSigWallet?]
    
    func save(_ multiSigWalletData: [String : Any], success: ((OSTMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ multiSigWalletDataArray: Array<[String: Any]>, success: ((Array<OSTMultiSigWallet>?, Array<OSTMultiSigWallet>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
