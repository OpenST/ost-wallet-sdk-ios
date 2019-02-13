//
//  OstSdkBaseDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OstSdkBaseDatabase {
    private(set) var database: FMDatabase
    private(set) var databaseQueue: FMDatabaseQueue?
    
    init(_ dbName: String) {
        database = FMDatabase(path: OstSdkBaseDatabase.dbPath(dbName))
        databaseQueue = FMDatabaseQueue(path: OstSdkBaseDatabase.dbPath(dbName))
        if !database.isOpen {
           database.open()
        }
        
        runMigration()
        print("Init called")
    }
    
    func runMigration() {
        fatalError("runMigration did not override")
    }
    
    //MARK: - private functions
    private class func dbPath(_ dbName: String) -> String {
        self.craeteDBIfRequired(dbName)
        
        let docPath: Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir: String = docPath.first!
        let dbPath = NSURL(fileURLWithPath:documentsDir).appendingPathComponent(dbName)
        
        Logger.log(message: "DB path", parameterToPrint: dbPath!.absoluteString)
        return dbPath!.absoluteString
    }
    
    private class func craeteDBIfRequired(_ dbName: String) {
        let filemanager = FileManager.default
        let path = filemanager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(dbName)
        if !filemanager.fileExists(atPath: (path?.path)!) {
            Logger.log(message: "Creating file at location", parameterToPrint: String(describing: path?.path))
            filemanager.createFile(atPath: (path?.path)!, contents: nil, attributes: nil)
        }
    }
}
