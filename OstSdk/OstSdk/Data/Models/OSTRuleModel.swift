//
//  OSTRuleModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTRuleModel: class {
    
    func get(_ id:  String) throws -> OSTRule?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTRule?]
    
    func save(_ ruleData: [String : Any], success: ((OSTRule?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ ruleDataArray: Array<[String: Any]>, success: ((Array<OSTRule>?, Array<OSTRule>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
