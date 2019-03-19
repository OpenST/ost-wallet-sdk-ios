/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk

class OstRuleTests: XCTestCase {
    
    var JSONObject = ["id": "123a",
                      "token_id": "1234",
                      "name": "ASCKJS",
                      "address": "123",
                      "abi": "JSON_STRING_NEEDS_PARSING",
                      "call_prefixes" : ["a": "b"],
                      "updated_timestamp": "123..."] as [String : Any]
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitEntity() throws {
        XCTAssertNotNil(try OstRule.storeEntity(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstRule? = try OstRuleModelRepository.sharedRule.getById("123a") as? OstRule
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.address, JSONObject["address"] as? String, "address is not same")
    }
    
    func testUpdateEntity() throws {
        JSONObject["address"] = "4dt2"
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstRule.storeEntity(JSONObject), "Entity should not be nil")
        let entity: OstRule? = try OstRuleModelRepository.sharedRule.getById("123a") as? OstRule
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.address, JSONObject["address"] as? String, "address is not same")
    }
    
    // This is an example of a performance test case.
    func testPerformanceExample() {
        self.measure {
                // Put the code you want to measure the time of here.
        }
    }
}
