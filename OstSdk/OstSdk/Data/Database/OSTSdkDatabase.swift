//
//  OstSdkDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTSdkDatabase {
    private static let dbName: String = "OSTSDK-ios.sqlite";
    private(set) var database: FMDatabase
    
    static let sharedInstance = OSTSdkDatabase()
    
    init() {
        database = FMDatabase(path: OSTSdkDatabase.dbPath())
        database.open()
        let migrationManager = OSTMigrationManager(database: database, bundle: Bundle(for: type(of: self)))
        migrationManager.runMigrations()
        database.close()
        print("Init called")
    }
    
    //MARK: - fileprivate functions
    fileprivate class func dbPath() -> String {
        self.craeteDBIfRequired()
        
        let docPath: Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir: String = docPath.first!
        let dbPath = NSURL(fileURLWithPath:documentsDir).appendingPathComponent(dbName)
        
        print("DB path : \(dbPath!.absoluteString)")
        return dbPath!.absoluteString
    }
    
    fileprivate class func craeteDBIfRequired() {
        let filemanager = FileManager.default
        let path = filemanager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(OSTSdkDatabase.dbName)
        if !filemanager.fileExists(atPath: (path?.path)!) {
            print("Creating file at location : \(String(describing: path?.path))")
            filemanager.createFile(atPath: (path?.path)!, contents: nil, attributes: nil)
        }
    }
}
