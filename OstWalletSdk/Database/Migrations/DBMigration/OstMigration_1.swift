/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import FMDB

class OstMigration_1: OstBaseMigration {
    
    override func version() -> Int {
        return 1
    }
    
    override func getExecuteStatement() -> String {
        let statement: String = """
            CREATE TABLE IF NOT EXISTS rules (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS tokens (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS token_holders (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS sessions (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS transactions (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS device_managers (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS devices (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);            
            """
        
        return statement
    }
}
