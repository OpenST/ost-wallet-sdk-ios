//
//  OSTSdkBaseDatabase.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTSdkBaseDatabase {
    private(set) var database: FMDatabase
    init(_ dbName: String) {
        database = FMDatabase(path: OSTSdkBaseDatabase.dbPath(dbName))
        database.open()
        runMigration()
        database.close()
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
        
        print("DB path : \(dbPath!.absoluteString)")
        return dbPath!.absoluteString
    }
    
    private class func craeteDBIfRequired(_ dbName: String) {
        let filemanager = FileManager.default
        let path = filemanager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(dbName)
        if !filemanager.fileExists(atPath: (path?.path)!) {
            print("Creating file at location : \(String(describing: path?.path))")
            filemanager.createFile(atPath: (path?.path)!, contents: nil, attributes: nil)
        }
    }
}
