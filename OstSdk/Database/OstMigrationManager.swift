//
//  OstMigrationManager.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

internal class OstMigrationManager{
    // DB queries
    fileprivate static let cMigrationTableQ = "CREATE TABLE IF NOT EXISTS schema_migrations (version Int PRIMARY KEY NOT NULL);"
    fileprivate static let sLastMigrationQ = "Select MAX(version) AS version FROM schema_migrations"
    fileprivate static let iVersionQ = "INSERT INTO schema_migrations (version) VALUES (:version)"
    fileprivate static let versionString = "version"
    
    // Latest migration version.
    // @dev Update this if new migration file is added else it will not run
    // For more details see OST_MIGRATION_README.md
    fileprivate static let verisonInt: Int = 1
    
    // Migration files prefix string
    fileprivate static let migrationFilePrefix: String = "OstMigration_"
    
    // Getter for migration prefix
    private var migrationPrefix: String {
        return OstMigrationManager.migrationFilePrefix
    }
    
    // Get the latest migration version
    var version: Int {
        return OstMigrationManager.verisonInt
    }
    
    private let database: FMDatabase
    private let bundle: Bundle
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - database: FMDatabase object
    ///   - bundle: Bundle object
    init(database: FMDatabase, bundle: Bundle) {
        self.database = database
        self.bundle = bundle
    }
    
    //MARK: - class methods
    
    /// Run migrations
    func runMigrations() {
        // Create migration table if does not exists
        if (self.createMigrationTable()){
            // Execute migrations
            executeMigration()
        }
    }
    
    //MARK: - fileprivate methods
    
    /// Create migration table
    ///
    /// - Returns: `true` if migration table is created otherwise false
    fileprivate func createMigrationTable() -> Bool {
        // This statement will create table if it doesnot exists
        return database.executeStatements(OstMigrationManager.cMigrationTableQ)
    }
    
    /// Execute migrations
    fileprivate func executeMigration() {
        // Get the last executed migration number
        let savedVersion = self.getLastMigration()
        // Run the migration for the latest files
        for var currentVersion in savedVersion..<version{
            currentVersion += 1
            let classOb = stringClassFromString("\(migrationPrefix)\(currentVersion)") as! OstBaseMigration.Type
            let migrationClass = classOb.init(db: database)
            let isExecutionSuccess = migrationClass.execute()
            if isExecutionSuccess{
                _ = updateVersionInMigrationTable(version: String(migrationClass.version()))
            }else{
                break
            }
        }
    }
    
    /// Get the latest migration version
    ///
    /// - Returns: Latest version
    fileprivate func getLastMigration() -> Int {
        var version: Int = 0
        let resultSet: FMResultSet = try! database.executeQuery(OstMigrationManager.sLastMigrationQ, values: nil)
        
        while resultSet.next(){
            version = max(version, Int(resultSet.int(forColumn: OstMigrationManager.versionString)))
        }
        // Logger.log(message: "getLastMigration", parameterToPrint: version)
        return version
    }
    
    /// Get the class from string
    ///
    /// - Parameter className: Class name string
    /// - Returns: Class
    fileprivate func stringClassFromString(_ className: String) -> AnyClass! {
        // Get namespace
        let namespace = bundle.infoDictionary!["CFBundleExecutable"] as! String;
        let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;
        // Logger.log(message: "OstMigrationManager :: namespace : \(namespace)")
        // Logger.log(message: "OstMigrationManager :: cls : \(cls)")
        // return AnyClass!
        return cls;
    }
    
    /// Update the migration version
    ///
    /// - Parameter version: Migration version
    /// - Returns: `true` if success otherwise `false`
    fileprivate func updateVersionInMigrationTable(version: String) -> Bool {
        // Logger.log(message: "updateVersionInMigrationTable : \(version)")
        let intVersion: Int = Int(version) ?? -1
        if(intVersion > -1){
            return database.executeUpdate(OstMigrationManager.iVersionQ, withParameterDictionary:["version":version])
        }
        return false
    }
}
