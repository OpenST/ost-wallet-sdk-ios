////
////  OstSecureKeyTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 08/02/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstSecureKeyTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testInitEntity() throws {
//        let exceptionObj = expectation(description: "Get Token with callback")
//        
//        let privateKey = "Aniket"
//        let identifier = "1234"
//        let privateKeyData = privateKey.data(using: .utf8)!
//        let secureKey = OstSecureKey(address: identifier, privateKeyData: privateKeyData, isSecureEnclaveEnrypted: false)
////        let entity = OstSecureKeyRepository.sharedSecureKey.insertOrUpdateEntity(secureKey)
//        
//        let dbSecureKey = try OstSecureKeyRepository.sharedSecureKey.getById(identifier)
//        
//        print(dbSecureKey)
//        waitForExpectations(timeout: 300) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//        }
//    }
//    
//    func testGetEntity() throws {
//      
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
