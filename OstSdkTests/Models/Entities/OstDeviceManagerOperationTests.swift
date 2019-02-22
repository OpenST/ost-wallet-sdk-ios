//
//  OstDeviceManagerOperationTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstDeviceManagerOperationTests: XCTestCase {

    var JSONObject = [
        "id": "123f",
        "user_id": "13a",
        "device_manager_id": "123a",
        "device_manager_address": "32142134a",
        "kind": "AUTHORIZE_DEVICE",
        "operation": "CALL",
        "safeTxGas": 123124,
        "calldata": "0xabc",
        "raw_calldata": [],
        "signatures": [
            "0x829bd824b0....": "0xab0101..."
        ],
        "status": "CREATED/RELAYING/QUEUED/SUBMITTED/SUCCESS/FAIL",
        "uts": "123..."
        ] as [String : Any]
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEntity() throws {
        XCTAssertNotNil(try OstDeviceManagerOperation.parse(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstDeviceManagerOperation? = try OstDeviceManagerOperationRepository.sharedDeviceManagerOperation.getById("123f") as? OstDeviceManagerOperation
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.id, JSONObject["id"] as? String, "address is not same")
        XCTAssertEqual(entity?.user_id, JSONObject["user_id"] as? String, "address is not same")
    }
    
    func testUpdateEntity() throws {
        JSONObject["user_id"] = "aa1"
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstDeviceManagerOperation.parse(JSONObject), "Entity should not be nil")
        let entity: OstDeviceManagerOperation? = try OstDeviceManagerOperationRepository.sharedDeviceManagerOperation.getById("123f") as? OstDeviceManagerOperation
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.updated_timestamp, JSONObject["updated_timestamp"] as? Int, "address is not same")
        XCTAssertEqual(entity?.user_id, JSONObject["user_id"] as? String, "address is not same")
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
