//
//  OstTestAPITests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstTokensAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetTokenHoder() throws {
        let exceptionObj = expectation(description: "Get Token with callback")
         
        try OstMockTokenAPI().getToken(success: { (successResponse) in
            XCTAssertNotNil(successResponse)
            exceptionObj.fulfill()
        }, failuar: { (failuarResponse) in
            Logger().DLog(message: "failuar", parameterToPrit: failuarResponse)
            exceptionObj.fulfill()
            XCTAssertFalse(true, "received failuar response.")
        })
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
