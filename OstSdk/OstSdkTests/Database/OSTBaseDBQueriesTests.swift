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
        
        XCTAssertTrue((db == OSTSdkDatabase.sharedInstance.database), "Database instances are same")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
//
//    func testDBInsert() {
//        let params: Dictionary<String,Any> = ["id":1, "name":"value tobe inserted for id 1..."]
//        let userEntity: OSTUserEntity? = try! OSTUserEntity(jsonParam: params)
//        let isSuccess = OSTUserDbQueries().insertInDB(params: userEntity!)
//        XCTAssertTrue(isSuccess, "Value inserted successfully")
//    }
//    
//    func testDBUpdate() {
//        let params: Dictionary<String,Any> = ["id":2, "name":"value tobe Updated for id 2..."]
//        let userEntity: OSTUserEntity? = try! OSTUserEntity(jsonParam: params)
//        let isSuccess = OSTUserDbQueries().updateInDB(params: userEntity!)
//        
//        XCTAssertTrue(isSuccess, "Value updated successfully")
//    }
//    
//    func testBulkInsert() {
//        let params: Array<[String: Any]> = [["id":3, "name":"value tobe inserted for id 3..."],
//                                            ["id":4, "name":"value tobe inserted for id 4..."],
//                                            ["id":5, "name":"value tobe inserted for id 5..."]
//        ]
//        var paramsArray: Array<OSTUserEntity> = []
//        for param in params {
//            let userEntity: OSTUserEntity? = try! OSTUserEntity(jsonParam: param)
//            paramsArray.append(userEntity!)
//        }
//        
//        let (successArray, failuarArray) = OSTUserDbQueries().bulkInsertInDB(params: paramsArray)
//        
//        XCTAssertTrue((successArray.count == params.count), "Bulk data inserted successfully...")
//        XCTAssertTrue((failuarArray.count == 0), "\n******\nBulk data inserted failed...\n\(failuarArray)")
//    }
//    
//    func testBulkUpdate() {
//        let params: Array<[String: Any]> = [["id":3, "name":"value tobe updated for id 3..."],
//                                            ["id":4, "name":"value tobe updated for id 4..."],
//                                            ["id":5, "name":"value tobe updated for id 5..."]
//        ]
//        var paramsArray: Array<OSTUserEntity> = []
//        for param in params {
//            let userEntity: OSTUserEntity? = try! OSTUserEntity(jsonParam: param)
//            paramsArray.append(userEntity!)
//        }
//        let (successArray, failuarArray) = OSTUserDbQueries().bulkUpdateInDB(params: paramsArray)
//        
//        XCTAssertTrue((successArray.count == params.count), "Bulk data updated successfully...")
//        XCTAssertTrue((failuarArray.count == 0), "\n******\nBulk data updated failed...\n\(failuarArray)")
//    }
//    
//    func testDeleteParticularEntryTable() {
//        let deleteId = "4"
//        let isDeleteSuccess = OSTUserDbQueries().deleteForId(String(deleteId))
//        
//        XCTAssertTrue(isDeleteSuccess, "Entry deleted  successfully...")
//    }
//    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
