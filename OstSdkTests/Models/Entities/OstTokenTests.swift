////
////  OstTokenTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 30/01/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstTokenTests: XCTestCase {
//
//    var JSONObject = [
//        "id": "123a",
//        "name": "aniket",
//        "symbol": "aaa",
//        "conversion_factor": "",
//        "total_supply": 123143535325431,
//        "origin_chain": [
//            "chain_id": "1",
//            "branded_token": "",
//            "organization": ["contract": "", "owner": ""],
//            "stakers": []
//        ],
//        "auxiliary_chains": [
//        [
//        "chain_id": "1409",
//        "utility_branded_token": "",
//        "commission_beneficiary": "",
//        "organization": ["contract": "", "owner": ""],
//        "credit_holder": "If funds are in the Contract. How would the expired credits will be retrieved?"
//        ]
//        ]
//        ] as [String : Any]
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
//        XCTAssertNotNil(try OstToken.parse(JSONObject), "Entity should not be nil")
//    }
//    
//    func testGetEntity() throws {
//        let entity: OstToken? = try OstTokenRepository.sharedToken.getById("123a") as? OstToken
//        XCTAssertNotNil(entity, "entity should not be nil")
//        XCTAssertEqual(entity?.id, JSONObject["id"] as? String, "address is not same")
//        XCTAssertEqual(entity?.symbol, JSONObject["symbol"] as? String, "address is not same")
//    }
//    
//    func testUpdateEntity() throws {
//        JSONObject["symbol"] = "aa1"
//        JSONObject["updated_timestamp"] = Date.timestamp()
//        XCTAssertNotNil(try OstToken.parse(JSONObject), "Entity should not be nil")
//        let entity: OstToken? = try OstTokenRepository.sharedToken.getById("123a") as? OstToken
//        XCTAssertNotNil(entity, "entity should not be nil")
//        XCTAssertEqual(entity?.updated_timestamp, JSONObject["updated_timestamp"] as? Int, "address is not same")
//        XCTAssertEqual(entity?.symbol, JSONObject["symbol"] as? String, "address is not same")
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
