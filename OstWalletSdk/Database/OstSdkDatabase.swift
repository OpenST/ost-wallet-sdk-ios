/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


class OstSdkDatabase: OstSdkBaseDatabase {
    fileprivate static let dbName: String = "OstSDK-ios.sqlite";
    static let sharedInstance = OstSdkDatabase(OstSdkDatabase.dbName)

    /// Run migration
    override func runMigration() {
        let keyMigrationManager = OstMigrationManager(database: database,
                                                      bundle: Bundle(for: type(of: self)))
        keyMigrationManager.runMigrations()
    }
}
