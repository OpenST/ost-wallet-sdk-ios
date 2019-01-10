//
//  OSTSdkKeyDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTSdkKeyDatabase: OSTSdkBaseDatabase {
    private static let dbName: String = "OSTSDKKey-ios.sqlite";
    static let sharedInstance = OSTSdkKeyDatabase(OSTSdkKeyDatabase.dbName)
    
    override func runMigration() {
        let keyMigrationManager = OSTKeyMigrationManager(database: database, bundle: Bundle(for: type(of: self)))
        keyMigrationManager.runMigrations()
    }
}
