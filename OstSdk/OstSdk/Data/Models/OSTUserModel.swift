//
//  OSTUserModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTUserModel: class {
    
    func get(_ id:  String) throws -> OSTUser?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTUser?]
    
    func save(_ userData: [String : Any], success: ((OSTUser?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ userDataArray: Array<[String: Any]>, success: ((Array<OSTUser>?, Array<OSTUser>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?) 
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
