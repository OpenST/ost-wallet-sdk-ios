//
//  OSTKeyMigration_1.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTKeyMigration_1: OSTBaseMigration {
    
    override func version() -> Int {
        return 1
    }
    
    override func getExecuteStatement() -> String {
        let statement: String = """
                    CREATE TABLE IF NOT EXISTS secure_keys (key TEXT PRIMARY KEY NOT NULL, data BLOB);
                    """
       return statement
    }
}
