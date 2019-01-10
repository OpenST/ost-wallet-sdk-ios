//
//  OstSdkDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation


class OSTSdkDatabase: OSTSdkBaseDatabase {
    fileprivate static let dbName: String = "OSTSDK-ios.sqlite";
    static let sharedInstance = OSTSdkDatabase(OSTSdkDatabase.dbName)

    override func runMigration() {
        let keyMigrationManager = OSTMigrationManager(database: database, bundle: Bundle(for: type(of: self)))
        keyMigrationManager.runMigrations()
    }
}
