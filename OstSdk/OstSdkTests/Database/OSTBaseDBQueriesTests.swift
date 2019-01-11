//
//  OSTBaseDBQueries.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 07/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
import FMDB
@testable import OstSdk

class OSTBaseDBQueries: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let db: FMDatabase = OSTSdkDatabase.sharedInstance.database
        let keyDB: FMDatabase = OSTSdkKeyDatabase.sharedInstance.database
        
        XCTAssertTrue((db == OSTSdkDatabase.sharedInstance.database), "Database instances are same")
        XCTAssertTrue((keyDB == OSTSdkKeyDatabase.sharedInstance.database), "Database instances are same")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
  
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
