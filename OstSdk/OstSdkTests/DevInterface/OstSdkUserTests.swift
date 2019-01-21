////
////  OstSdkUserTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 14/12/18.
////  Copyright © 2018 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstSdkUserTests: XCTestCase {
//    
//    var params: Dictionary<String,String> = ["id":"1",
//                                          "name":"value tobe inserted for id 1",
//                                          "parent_id":"2",
//                                          "status":"active"]
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//    
//    func testGetUser() {
//        var userId = "1"
//        XCTAssertNoThrow(try OstSdk.getUser(userId), "should not throw error")
//        do {
//            let OstUser: OstUser? = try OstSdk.getUser(userId)
//            XCTAssertNotNil(OstUser, "User should not nil")
//            XCTAssertTrue(params["name"] == OstUser!.name, "name should be same")
////            XCTAssertTrue(params["parent_id"] == OstUser!.parnet_id, "name should be same")
//        }catch let error {
//            XCTAssertNil(error, "Error should not occure")
//        }
//        
//        userId = "10000"
//        XCTAssertNil(try OstSdk.getUser(userId), "User should be nil")
//        XCTAssertNoThrow(try OstSdk.getUser(userId), "should not throw error")
//        
//        userId = "10000 a"
//        XCTAssertThrowsError(try OstSdk.getUser(userId), "should throw error")
//        
//        userId = "Select * from"
//        XCTAssertThrowsError(try OstSdk.getUser(userId), "should throw error")
//    }
//    
//    func testInitUser() {
//       
////        try OstSdk.initUser(params)
//        
//        params = ["id":"1#",
//                  "name":"value tobe inserted for id 1",
//                  "parent_id":"2",
//                  "status":"active"]
//        
//        try OstSdk.initUser(params)
//    }
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//    
//}
