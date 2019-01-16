//
//  OstTokenHolderSessionModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstTokenHolderSessionModel: class {
    
    func get(_ id:  String) throws -> OstTokenHolderSession?
    
    func getAll(_ ids:  Array<String>) -> [String: OstTokenHolderSession?]
    
    func save(_ tokenHolderSessionData: [String : Any], success: ((OstTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ tokenHolderSessionDataArray: Array<[String: Any]>, success: ((Array<OstTokenHolderSession>?, Array<OstTokenHolderSession>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
