//
//  OstExecutableRuleModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstExecutableRuleModel: class {
    
    func get(_ id:  String) throws -> OstExecutableRule?
    
    func getAll(_ ids:  Array<String>) -> [String: OstExecutableRule?]
    
    func save(_ executableRuleData: [String : Any], success: ((OstExecutableRule?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ executableRuleDataArray: Array<[String: Any]>, success: ((Array<OstExecutableRule>?, Array<OstExecutableRule>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
