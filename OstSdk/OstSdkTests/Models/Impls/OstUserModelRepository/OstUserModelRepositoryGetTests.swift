////
////  OstUserModelRepositoryTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 11/12/18.
////  Copyright © 2018 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstUserModelRepositoryGetTests: XCTestCase {
//    
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//    
//    func testGet() {
//        do{
//            let id = "2"
//            let userEntity: OstUser? = try OstUserModelRepository.sharedUser.get(id)
//            print(userEntity?.name ?? "unknown")
//            print("testGetUser :: id :: \(id) :: userEntity :: \(userEntity?.data ?? [:])")
//            XCTAssertTrue(userEntity?.id == id, "entity is not same")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
//        testGetInMemory()
//    }
//
//    func testGetInMemory() {
//        do{
//            let id = "1"
//            let userEntity: OstUser? = try OstUserModelRepository.sharedUser.get(id)
//            print("testGetUser :: id :: \(id) :: userEntity :: \(userEntity?.data ?? [:])")
//            XCTAssertTrue(userEntity?.id == id, "entity is not same")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
//
//    }
//
//    func testgetUser1() {
//        do{
//            let id = "2"
//            let userEntity: OstUser? = try OstUserModelRepository.sharedUser.get(id)
//            print("testGetUser :: id :: \(id) :: userEntity :: \(userEntity?.data ?? [:])")
//            XCTAssertTrue(userEntity?.id == id, "entity is not same")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
//    }
//
//    func testGetUserWrongVal() {
//        let id = "100000000000"
//        XCTAssertNil(try OstUserModelRepository.sharedUser.get(id),"User object is not nil")
//    }
//
//    func testGetUserWrongId() {
//        let id = "1#"
//        XCTAssertThrowsError(try OstUserModelRepository.sharedUser.get(id))
//    }
//
//    func testBulkGetUsers() {
//        let ids = ["1","2","3"]
//        let userEntities: [String: OstUser?] =  OstUserModelRepository.sharedUser.getAll(ids)
//        XCTAssertTrue(userEntities.count == ids.count)
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
