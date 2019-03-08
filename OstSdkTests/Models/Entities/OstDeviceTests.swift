//
//  OstDeviceEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstDeviceTests: XCTestCase {

    var JSONObject = [
        "address": "0x12",
        "user_id": "abcd-kdlk...",
        "deviceName": "0xsdsd..",
        "status": "AUTHORIZING",
        "updated_timestamp": 12344,
        "device_name": "",
        "device_uuid": ""
        ] as [String : Any]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEntity() throws {
        XCTAssertNotNil(try OstDevice.storeEntity(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstDevice? = try OstDeviceRepository.sharedDevice.getById("0x12") as? OstDevice
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.address, JSONObject["address"] as? String, "address is not same")
    }
    
    func testUpdateEntity() throws {
        JSONObject["deviceName"] = "4dt2"
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstDevice.storeEntity(JSONObject), "Entity should not be nil")
        let entity: OstDevice? = try OstDeviceRepository.sharedDevice.getById("0x12") as? OstDevice
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.deviceName, JSONObject["deviceName"] as? String, "address is not same")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
