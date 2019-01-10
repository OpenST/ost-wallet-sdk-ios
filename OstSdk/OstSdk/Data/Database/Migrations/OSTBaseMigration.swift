//
//  BaseMigration.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTBaseMigration {
    
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
