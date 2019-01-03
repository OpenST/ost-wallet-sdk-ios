//
//  OSTTokenHolderSessionModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTTokenHolderSessionModel: class {
    
    func get(_ id:  String) throws -> OSTTokenHolderSession?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTTokenHolderSession?]
    
    func save(_ tokenHolderSessionData: [String : Any], success: ((OSTTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ tokenHolderSessionDataArray: Array<[String: Any]>, success: ((Array<OSTTokenHolderSession>?, Array<OSTTokenHolderSession>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
