//
//  OSTTokenModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTTokenModel: class {
    
    func get(_ id:  String) throws -> OSTToken?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTToken?]
    
    func save(_ tokenData: [String : Any], success: ((OSTToken?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ tokenDataArray: Array<[String: Any]>, success: ((Array<OSTToken>?, Array<OSTToken>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
