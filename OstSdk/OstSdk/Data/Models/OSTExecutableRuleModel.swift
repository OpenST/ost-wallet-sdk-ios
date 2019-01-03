//
//  OSTExecutableRuleModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTExecutableRuleModel: class {
    
    func get(_ id:  String) throws -> OSTExecutableRule?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTExecutableRule?]
    
    func save(_ executableRuleData: [String : Any], success: ((OSTExecutableRule?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ executableRuleDataArray: Array<[String: Any]>, success: ((Array<OSTExecutableRule>?, Array<OSTExecutableRule>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
