//
//  OstSdkKeyDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSdkKeyDatabase: OstSdkBaseDatabase {
    private static let dbName: String = "OstSDKKey-ios.sqlite";
    static let sharedInstance = OstSdkKeyDatabase(OstSdkKeyDatabase.dbName)
    
    override func runMigration() {
        let keyMigrationManager = OstKeyMigrationManager(database: database, bundle: Bundle(for: type(of: self)))
        keyMigrationManager.runMigrations()
    }
}
