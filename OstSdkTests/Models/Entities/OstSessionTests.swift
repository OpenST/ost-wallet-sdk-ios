////
////  OstSessionEntityTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 30/01/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstSessionTests: XCTestCase {
//
//    var JSONObject = [
//        "address": "0x12q",
//        "token_holder_address": "0xcasg",
//        "user_id": "abcd-kdlkd",
//        "expiration_height": "12344",
//        "spending_limit": "1234",
//        "nonce":0,
//        "status": "AUTHORISED",
//        "updated_timestamp": "12344"
//    ] as [String: Any]
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testInitEntity() throws {
//        XCTAssertNotNil(try OstSession.parse(JSONObject), "Entity should not be nil")
//    }
//    
//    func testGetEntity() throws {
//        let entity: OstSession? = try OstSessionRepository.sharedSession.getById("0x12q") as? OstSession
//        XCTAssertNotNil(entity, "entity should not be nil")
//        XCTAssertEqual(entity?.address, JSONObject["address"] as? String, "address is not same")
//    }
//    
//    func testGetByParentId() throws {
//        let entities: [OstSession]? = try OstSessionRepository.sharedSession.getByParentId("abcd-kdlkd") as? [OstSession]
//        XCTAssertNotNil(entities?.first, "entity should not be nil")
//        XCTAssertEqual(entities?.first!.address, JSONObject["address"] as? String, "address is not same")
//    }
//    
//    func testGetByInvalidParentId() throws {
//        let entities: [OstTokenHolder]? = try OstTokenHolderRepository.sharedTokenHolder.getByParentId("1233") as? [OstTokenHolder]
//        XCTAssertNil(entities?.first, "entity should be nil")
//    }
//    
//    func testUpdateEntity() throws {
//        JSONObject["nonce"] = 1
//        JSONObject["updated_timestamp"] = Date.timestamp()
//        XCTAssertNotNil(try OstSession.parse(JSONObject), "Entity should not be nil")
//        let entity: OstSession? = try OstSessionRepository.sharedSession.getById("0x12q") as? OstSession
//        XCTAssertNotNil(entity, "entity should not be nil")
//        XCTAssertEqual(entity?.nonce, JSONObject["nonce"] as? Int, "address is not same")
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
