/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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
        return "select * from \(activityName()) where parent_id=\"\(parentId)\" and status=\"AUTHORIZED\""
    }
}
