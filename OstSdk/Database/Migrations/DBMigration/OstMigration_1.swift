//
//  Migration_1.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

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
            CREATE TABLE IF NOT EXISTS device_manager_operations (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS credites (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS secure_keys (key TEXT PRIMARY KEY NOT NULL, data BLOB);
            """
        
        return statement
    }
}
