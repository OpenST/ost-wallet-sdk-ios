//
//  OstKeyMigrationManager.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstKeyMigrationManager: OstMigrationManager {
    
    fileprivate static let verisonInt: Int = 1
    fileprivate static let migrationFilePrefix: String = "OstKeyMigration_"
    
    override var migrationPrefix: String {
        return OstKeyMigrationManager.migrationFilePrefix
    }
    
    override var version: Int {
        return OstKeyMigrationManager.verisonInt
    }
}
