//
//  DBQueriesProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 07/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstDBQueriesProtocol {
    
    func selectForId(_ id: String) -> Dictionary<String, Any>?
    
    func selectForIds(_ ids: Array<String>) -> [String: [String:Any]?]?
    
//    func save(_ entity: OstBaseEntity) -> Bool
//    
//    func saveAll(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?, Array<OstBaseEntity>?)
    
    func deleteForId(_ id: String) -> Bool
    
    func bulkDeleteForIds(_ ids: Array<String>) -> Bool
}
