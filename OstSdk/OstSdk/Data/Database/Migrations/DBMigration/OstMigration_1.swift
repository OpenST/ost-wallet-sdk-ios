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
            CREATE TABLE IF NOT EXISTS token_holder_sessions (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS executable_rule_entities (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS multi_sig (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS multi_sig_wallets (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            CREATE TABLE IF NOT EXISTS multi_sig_operations (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
            """
        
        return statement
    }
    
//    override func execute() -> Bool {
//        let createTable: String = """
//            CREATE TABLE IF NOT EXISTS rules (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS economies (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS token_holders (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS token_holder_sessions (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS executable_rule_entities (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS secure_keys (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS multi_sig (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS multi_sig_wallets (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            CREATE TABLE IF NOT EXISTS multi_sig_operations (id TEXT PRIMARY KEY NOT NULL, parent_id TEXT, data BLOB, status TEXT DEFAULT 'active', uts timestamp);
//            """
//        let isSuccess: Bool = self.database.executeStatements(createTable)
//
//        print("Migration_1 :: isSuccess : \(isSuccess)")
//        return isSuccess
//    }
}
