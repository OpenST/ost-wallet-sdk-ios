//
//  OstMigrationManager.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

internal class OSTMigrationManager{
    
    fileprivate static let cMigrationTableQ = "CREATE TABLE IF NOT EXISTS schema_migrations (version Int PRIMARY KEY NOT NULL);"
    fileprivate static let sLastMigrationQ = "Select MAX(version) AS version FROM schema_migrations"
    fileprivate static let iVersionQ = "INSERT INTO schema_migrations (version) VALUES (:version)"
    fileprivate static let versionString = "version"
    
    fileprivate static let verisonInt: Int = 1
    fileprivate static let migrationFilePrefix: String = "OSTMigration_"
    
    var migrationPrefix: String {
        return OSTMigrationManager.migrationFilePrefix
    }
    
    var version: Int {
        return OSTMigrationManager.verisonInt
    }
    
    private let database: FMDatabase
    private let bundle: Bundle
    
    init(database: FMDatabase, bundle: Bundle) {
        self.database = database
        self.bundle = bundle
    }
    
    //MARK: - class methods
    func runMigrations() {
        if (self.createMigrationTable()){
            executeMigration()
        }
    }
    
    //MARK: - fileprivate methods
    fileprivate func createMigrationTable() -> Bool {
        return database.executeStatements(OSTMigrationManager.cMigrationTableQ)
    }
    
    fileprivate func executeMigration() {
        let savedVersion = self.getLastMigration()
        for var currentVersion in savedVersion..<version{
            currentVersion = currentVersion+1
            let classOb = stringClassFromString("\(migrationPrefix)\(currentVersion)") as! OSTBaseMigration.Type
            let migrationClass = classOb.init(db: database)
            let isExecutionSuccess = migrationClass.execute()
            if isExecutionSuccess{
                _ = updateVersionInMigrationTable(version: String(migrationClass.version()))
            }else{
                break
            }
        }
    }
    
    fileprivate func getLastMigration() -> Int {
        var version: Int = 0
        let resultSet: FMResultSet = try! database.executeQuery(OSTMigrationManager.sLastMigrationQ, values: nil)
        
        while resultSet.next(){
            version = max(version, Int(resultSet.int(forColumn: OSTMigrationManager.versionString)))
        }
        print("getLastMigration: \(version)")
        return version
    }
    
    fileprivate func stringClassFromString(_ className: String) -> AnyClass! {
        /// get namespace
        let namespace = bundle.infoDictionary!["CFBundleExecutable"] as! String;
        let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;
        print("OSTMigrationManager :: namespace : \(namespace)")
        print("OSTMigrationManager :: cls : \(cls)")
        // return AnyClass!
        return cls;
    }
    
    fileprivate func updateVersionInMigrationTable(version: String) -> Bool {
        print("updateVersionInMigrationTable : \(version)")
        let intVersion: Int = Int(version) ?? -1
        if(intVersion > -1){
            return database.executeUpdate(OSTMigrationManager.iVersionQ, withParameterDictionary:["version":version])
        }
        
        return false
    }
}
