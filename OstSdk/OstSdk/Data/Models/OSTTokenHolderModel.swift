//
//  OSTTokenHolderModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTTokenHolderModel: class {
    
    func get(_ id:  String) throws -> OSTTokenHolder?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTTokenHolder?]
    
    func save(_ tokenHolderData: [String : Any], success: ((OSTTokenHolder?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ tokenHolderDataArray: Array<[String: Any]>, success: ((Array<OSTTokenHolder>?, Array<OSTTokenHolder>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
