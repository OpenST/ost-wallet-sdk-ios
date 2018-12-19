//
//  OstSdkRuleTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstSdkRuleTests: XCTestCase {
    
    var params: Dictionary<String,String> = ["id": "123",
                                             "economy_id": "1234",
                                             "name": "ASCKJS",
                                             "address": "0x12..",
                                             "abi": "JSON_STRING_NEEDS_PARSING"]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetRule() {
        var ruleId = "123"
        XCTAssertNoThrow(try OstSdk.getRule(ruleId), "should not throw error")
        do {
            let ostRule: OSTRule? = try OstSdk.getRule(ruleId)
            XCTAssertNotNil(ostRule, "User should not nil")
            XCTAssertTrue(params["economy_id"] == ostRule!.economy_id , "economy_id should be same")
            XCTAssertTrue(params["name"] == ostRule!.name, "name should be same")
            XCTAssertTrue(params["address"] == ostRule!.address, "address should be same")
        }catch let error {
            XCTAssertNil(error, "Error should not occure")
        }
       
        ruleId = "10000"
        XCTAssertNil(try OstSdk.getRule(ruleId), "User should be nil")
        XCTAssertNoThrow(try OstSdk.getRule(ruleId), "should not throw error")
        
        ruleId = "10000 a"
        XCTAssertThrowsError(try OstSdk.getRule(ruleId), "should throw error")
        
        ruleId = "Select * from"
        XCTAssertThrowsError(try OstSdk.getRule(ruleId), "should throw error")
    }
    
    func testInitRule() {
        OstSdk.initRule(params, success: { (ostRule) in
            XCTAssertNotNil(ostRule, "Rule should not nil")
        }, failure: nil)
        
        params["id"] = "1#"
        OstSdk.initRule(params, success: nil, failure: { (error) in
            XCTAssertNotNil(error, "Should throw error")
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
