//
//  OSTEconomyModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTEconomyModel: class {
    
    func get(_ id:  String) throws -> OSTEconomy?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTEconomy?]
    
    func save(_ economyData: [String : Any], success: ((OSTEconomy?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ economyDataArray: Array<[String: Any]>, success: ((Array<OSTEconomy>?, Array<OSTEconomy>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
