//
//  OstCreditTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstCreditTests: XCTestCase {

    var JSONObject = [
        "id": "bc6dc9e1-6e62-4032-8862-6f664d8d7541",
        "amount": 234,
        "current_status": "",
        "user_ids": "1,2,3,4",
        "steps_complete": ""
    ] as [String: Any]
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEntity() throws {
        XCTAssertNotNil(try OstCredit.parse(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstCredit? = try OstCreditRepository.sharedCredit.getById(JSONObject["id"] as! String) as? OstCredit
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.id, JSONObject["id"] as? String, "address is not same")
        XCTAssertEqual(entity?.amount, JSONObject["amount"] as? Int, "address is not same")
    }
    
    func testUpdateEntity() throws {
        JSONObject["amount"] = 1
        JSONObject["updated_timestamp"] = Date.timestamp()-10
        XCTAssertNotNil(try OstCredit.parse(JSONObject), "Entity should not be nil")
        let entity: OstCredit? = try OstCreditRepository.sharedCredit.getById(JSONObject["id"] as! String) as? OstCredit
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.updated_timestamp, JSONObject["updated_timestamp"] as? Int, "address is not same")
        XCTAssertEqual(entity?.amount, JSONObject["amount"] as? Int, "address is not same")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
