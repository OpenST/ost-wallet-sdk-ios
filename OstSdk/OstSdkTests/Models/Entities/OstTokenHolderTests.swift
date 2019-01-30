//
//  OstTokenHolderTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstTokenHolderTests: XCTestCase {

    var JSONObject = [
        "user_id": "123",
        "address": "0x1",
        "updated_timestamp": 12344,
        "status": "Activated"
    ] as [String: Any]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEntity() throws {
        XCTAssertNotNil(try OstTokenHolder.parse(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstTokenHolder? = try OstTokenHolderRepository.sharedTokenHolder.getById("0x1") as? OstTokenHolder
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.address, JSONObject["address"] as? String, "address is not same")
    }
    
    func testGetByParentId() throws {
        let entities: [OstTokenHolder]? = try OstTokenHolderRepository.sharedTokenHolder.getByParentId("123") as? [OstTokenHolder]
        XCTAssertNotNil(entities?.first, "entity should not be nil")
        XCTAssertEqual(entities?.first!.address, JSONObject["address"] as? String, "address is not same")
    }
    
    func testGetByInvalidParentId() throws {
        let entities: [OstTokenHolder]? = try OstTokenHolderRepository.sharedTokenHolder.getByParentId("1233") as? [OstTokenHolder]
        XCTAssertNil(entities?.first, "entity should be nil")
    }
    
    func testUpdateEntity() throws {
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstTokenHolder.parse(JSONObject), "Entity should not be nil")
        let entity: OstTokenHolder? = try OstTokenHolderRepository.sharedTokenHolder.getById("0x1") as? OstTokenHolder
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.updated_timestamp, JSONObject["updated_timestamp"] as? Int, "address is not same")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
