//
//  OSTKeyMigrationManager.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTKeyMigrationManager: OSTMigrationManager {
    
    fileprivate static let verisonInt: Int = 1
    fileprivate static let migrationFilePrefix: String = "OSTKeyMigration_"
    
    override var migrationPrefix: String {
        return OSTKeyMigrationManager.migrationFilePrefix
    }
    
    override var version: Int {
        return OSTKeyMigrationManager.verisonInt
    }
}
