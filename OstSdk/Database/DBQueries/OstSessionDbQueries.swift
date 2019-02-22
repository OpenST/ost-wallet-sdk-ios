//
//  OstSessionDbQueries.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSessionDbQueries: OstBaseDbQueries {
    
    override func activityName() -> String{
        return "sessions"
    }
    
    func getActiveSessionsFor(_ parentId: String) throws -> [[String: Any?]]? {
        let selectByParentIdQuery = getSelectActiveSessionQueryForParentId(parentId)
        return try executeQuery(selectByParentIdQuery)
    }
    
    func getSelectActiveSessionQueryForParentId(_ parentId: String) -> String {
        return "select * from \(activityName) where parent_id=\"\(parentId)\" and status=AUTHORISED"
    }
}
