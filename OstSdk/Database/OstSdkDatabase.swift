//
//  OstSdkDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

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
