//
//  OstTokenModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstTokenModel: class {
    
    func get(_ id:  String) throws -> OstToken?
    
    func getAll(_ ids:  Array<String>) -> [String: OstToken?]
    
    func save(_ tokenData: [String : Any], success: ((OstToken?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ tokenDataArray: Array<[String: Any]>, success: ((Array<OstToken>?, Array<OstToken>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
