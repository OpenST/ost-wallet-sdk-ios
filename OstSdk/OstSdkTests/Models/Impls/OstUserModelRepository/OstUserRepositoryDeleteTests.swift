////
////  OstUserRepositoryDeleteTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 12/12/18.
////  Copyright © 2018 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstUserRepositoryDeleteTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testDeleteUser() {
//        let id = "1"
//        OstUserModelRepository.sharedUser.deleteForId(id, success: { (isSuccess) in
//            XCTAssertTrue(isSuccess, "Data is not deleted.")
//            if isSuccess {
//                self.testUserExistance(id)
//            }
//        })
//    }
//    
//    func testUserExistance(_ id: String) {
//        do {
//            let userEntity: OstUser? = try OstUserModelRepository.sharedUser.get(id)
//            XCTAssertTrue((userEntity == nil), "User entity should be nil")
//        }catch {
//            XCTAssertTrue(false, "should not receive error")
//        }
//    }
//    
//    func testNonExistingDeleteUser() {
//        let id = "100000000"
//        OstUserModelRepository.sharedUser.deleteForId(id, success: { (isSuccess) in
//            XCTAssertTrue(isSuccess, "Data is not deleted.")
//            if isSuccess {
//                self.testUserExistance(id)
//            }
//        })
//    }
//    
//    
//    func testDeleteUsers() {
//        OstUserModelRepository.sharedUser.deleteAll(["2","3"], success: { (isSuccess) in
//            XCTAssertTrue(isSuccess)
//        })
//    }
//    
//    func testDeleteUserWithInvalidId() {
//        OstUserModelRepository.sharedUser.deleteForId("1#", success: { (isSuccess) in
//            XCTAssertFalse(isSuccess)
//        })
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
