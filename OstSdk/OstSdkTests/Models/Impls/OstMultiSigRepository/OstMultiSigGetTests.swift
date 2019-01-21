////
////  OstMultiSigGetTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 03/01/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstMultiSigGetTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testGetMultiSig() {
//        do{
//            let id = "2"
//            let entity: OstMultiSig? = try OstMultiSigRepository.sharedMultiSig.get(id)
//            print("testGet :: id :: \(id) :: Entity :: \(entity?.data ?? [:])")
//            XCTAssertEqual(entity?.id, id, "entity is not same")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
//        testGetInMemoryMultiSig()
//    }
//    
//    func testGetInMemoryMultiSig() {
//        do{
//            let id = "2"
//            let entity: OstMultiSig? = try OstMultiSigRepository.sharedMultiSig.get(id)
//            print("testGet :: id :: \(id) :: Entity :: \(entity?.data ?? [:])")
//            XCTAssertEqual(entity?.id, id, "entity is not same")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
//        
//    }
//    
//    func testGetNonExistingMultiSig() {
//        do{
//            let id = "10000000"
//            let entity: OstMultiSig? = try OstMultiSigRepository.sharedMultiSig.get(id)
//            XCTAssertNil(entity, "ruleEntity shoule be nil")
//        }catch {
//            XCTAssertFalse(true, "error is not excepted.")
//        }
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
