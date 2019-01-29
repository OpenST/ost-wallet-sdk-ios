//
//  OstMultiSigEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstMultiSigEntityTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitMultiSig() throws {
      let multiSig =  ["user_id": "1a",
                       "address": "0x...",
                       "requirement": "1",
                       "nonce": "",
                       "updated_timestamp": "12344",
                       "status": "Activated"]
        
        XCTAssertNotNil(try OstMultiSig.parse(multiSig), "Entity should not be nil") 
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
