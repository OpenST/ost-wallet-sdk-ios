//
//  OstRuleModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstRuleModel: class {
    
    func get(_ id:  String) throws -> OstRule?
    
    func getAll(_ ids:  Array<String>) -> [String: OstRule?]
    
    func save(_ ruleData: [String : Any], success: ((OstRule?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ ruleDataArray: Array<[String: Any]>, success: ((Array<OstRule>?, Array<OstRule>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
