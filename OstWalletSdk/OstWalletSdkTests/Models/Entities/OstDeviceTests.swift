/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk

class OstDeviceTests: XCTestCase {

    var JSONObject = [
        "address": "0x12",
        "user_id": "abcd-kdlk...",
        "device_name": "0xsdsd..",
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
        JSONObject["device_name"] = "4dt2"
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstDevice.storeEntity(JSONObject), "Entity should not be nil")
        let entity: OstDevice? = try OstDeviceRepository.sharedDevice.getById("0x12") as? OstDevice
        XCTAssertNotNil(entity, "entity should not be nil")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
