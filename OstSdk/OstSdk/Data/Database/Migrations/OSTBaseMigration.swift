//
//  BaseMigration.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import FMDB

class OSTBaseMigration {
    
    let database: FMDatabase
    required init(db: FMDatabase) {
        self.database = db
    }
    
    func version() -> Int {
        return -1
    }
    func execute() -> Bool {
        fatalError("activityName didnot override in \(self)")
    }
  
}
