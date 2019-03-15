/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import FMDB

class OstBaseMigration {
    
    let database: FMDatabase
    required init(db: FMDatabase) {
        self.database = db
    }
    
    //************************ override mthods *************************
    func version() -> Int {
        return -1
    }
    
    func getExecuteStatement() -> String {
        fatalError("************ getExecuteStatement did not override ************")
    }
    //********************** override mthods ends ***********************
    
    func execute() -> Bool {
        let statement = getExecuteStatement()
        return executeStatement(statement)
    }
    
    func executeStatement(_ statement: String) -> Bool {
        let isSuccess: Bool = self.database.executeStatements(statement)
        return isSuccess
    }
    
}
