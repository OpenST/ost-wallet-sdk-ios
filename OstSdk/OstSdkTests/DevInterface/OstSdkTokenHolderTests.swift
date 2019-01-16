//
//  OstSdkTokenHolderTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstSdkTokenHolderTests: XCTestCase {
    
    var params: Dictionary<String,Any> = ["id": "1",
                                          "user_id": "1",
                                          "multisig_id": "1",
                                          "address": "0x1",
                                          "sessions": ["11","12"],
                                          "execute_rule_callprefix": "0x1"]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetTokenHolder() {
        var thId = "1"
        XCTAssertNoThrow(try OstSdk.getTokenHolder(thId), "should not throw error")
        do {
            let OstTH: OstTokenHolder? = try OstSdk.getTokenHolder(thId)
            XCTAssertNotNil(OstTH, "User should not nil")
            if (OstTH != nil){
                XCTAssertTrue(params["user_id"] as? String == OstTH!.user_id , "user_id should be same")
                XCTAssertTrue(params["multisig_id"] as? String == OstTH!.multisig_id, "multisig_id should be same")
                XCTAssertTrue(params["address"] as? String == OstTH!.address, "address should be same")
                XCTAssertTrue(params["execute_rule_callprefix"] as? String == OstTH!.execute_rule_callprefix, "execute_rule_callprefix should be same")
                if (OstTH!.sessions != nil) {
                    for (index, val) in OstTH!.sessions!.enumerated() {
                        let session = (params["sessions"] as! Array<String>)[index]
                        XCTAssertTrue((val == session),"\(val) and \(session) are not same")
                    }
                }
            }
        }catch let error {
            XCTAssertNil(error, "Error should not occure")
        }
        
        thId = "10000"
        XCTAssertNil(try OstSdk.getRule(thId), "User should be nil")
        XCTAssertNoThrow(try OstSdk.getRule(thId), "should not throw error")
        
        thId = "10000 a"
        XCTAssertThrowsError(try OstSdk.getRule(thId), "should throw error")
        
        thId = "Select * from"
        XCTAssertThrowsError(try OstSdk.getRule(thId), "should throw error")
    }
    
    func testInitTokenHolder() {
        OstSdk.initTokenHolder(params, success: { (OstRule) in
            XCTAssertNotNil(OstRule, "Rule should not nil")
        }, failure: nil)
        
        params["id"] = "1#"
        OstSdk.initTokenHolder(params, success: nil, failure: { (error) in
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
