//
//  OstTestAPITests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstTestAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetTokenHoder() throws {
        let expectation1 = expectation(description: "SomethingWithDelegate calls the delegate as the result of an async method completion")
        
        let params: [String : Any] = ["personal_sign_address":"0xf65c7a49981db56AED34beA4617E32e326ACf977",
                                         "token_id": "58",
                                         "user_id": "bcffc567-2881-4610-aa86-fa89f37bc197",
                                         "wallet_address": "0x60A20Cdf6a21a73Fb89475221D252865C695e302"]
        
        try OstTokensAPI().getToken(success: { (successResponse) in
            XCTAssertNotNil(successResponse)
            expectation1.fulfill()
        }, failuar: { (failuarResponse) in
            print(failuarResponse)
            expectation1.fulfill()
            XCTAssertFalse(true, "received failuar response.")
        })
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func test1() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
