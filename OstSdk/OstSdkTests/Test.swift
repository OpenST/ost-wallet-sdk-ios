//
//  Test.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 30/11/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class Test: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExecuteMigration(){
        let _ = OSTSdkDatabase.sharedInstance
    }
    
//    func testSingleInsert(){
//        let params: Dictionary<String,Any> = ["id":4, "name":"Aniket"]
//        let isSuccess = OSTUserDbQueries().insertInDB(params: params)
//        print("testSingleInsert :: isSuccess: \(isSuccess)")
//    }
//
//    func testSingleUpdate(){
//        let params: Dictionary<String,Any> = ["id":12, "name":"Aniket1"]
//        let isSuccess = OSTUserDbQueries().updateInDB(params: params)
//        print("testSingleUpdate :: isSuccess: \(isSuccess)")
//    }
//
//    func testBulkInsert(){
//        let params: Array<[String: Any]> = [["id":17, "name":"Aniket"],
//                                            ["id":15, "name":"Aniket"],
//                                            ["id":16, "name":"Aniket"]
//        ]
//        let (successArray, failuarArray) = OSTUserDbQueries().bulkInsertInDB(params: params)
//
//        print("testBulkInsert :: successArray : \(successArray)")
//        print("testBulkInsert :: failuarArray : \(failuarArray)")
//    }
//
//    func testBulkUpdate(){
//        let params: Array<[String: Any]> = [["id":17, "name":"Aniket1"],
//                                            ["id":15, "name":"Aniket1"],
//                                            ["id":16, "name":"Aniket2"]
//        ]
//        let (successArray, failuarArray) = OSTUserDbQueries().bulkUpdateInDB(params: params)
//
//        print("testBulkInsert :: successArray : \(successArray)")
//        print("testBulkInsert :: failuarArray : \(failuarArray)")
//    }
    
//    func testCallbacks(){
////        UserDbQueries().getText(text: "aniket") { (result) in
////            print("callbackFunciton: \(result)")
////        }
//        OSTUserDbQueries().test(completion: { (output) in
//            print("output : \(output)")
//        })
//        print("here")
//    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
