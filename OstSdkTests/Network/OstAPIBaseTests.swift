//
//  OstAPIBaseTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstAPIBaseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    class OstGetAPIMockBase: OstAPIBase {
        override init(userId: String) {
            super.init(userId: userId)
        }
        
        override var getBaseURL: String {
             return "http://127.0.0.1:4040/api/users/5c5ad125a5c9b42506d50366"
        }
        
        override var getResource: String {
            return ""
        }
    }
    func testGetAPI() {
        let exceptionObj = expectation(description: "Get user from local with callback")
        
        OstGetAPIMockBase(userId: "123").get(params: nil, onSuccess: { (successObj) in
            exceptionObj.fulfill()
            XCTAssertNotNil(successObj)
        }) { (failureResponse) in
            exceptionObj.fulfill()
            XCTAssertNil(failureResponse, "received onFailure response.")
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    class OstPostAPIMockBase: OstAPIBase {
        override init(userId: String) {
            super.init(userId: userId)
        }
        
        
        override var getBaseURL: String {
            return "http://127.0.0.1:4040/api/users"
        }
        
        override var getResource: String {
            return ""
        }
    }
    func testPostAPI() {
        let exceptionObj = expectation(description: "Get user from local with callback")
        let params = ["username": "aaaaa",
                      "mobile_number": OstUtils.toString(Date.timestamp())]
        OstPostAPIMockBase(userId: "123").post(params: params as [String : AnyObject], onSuccess: { (successObj) in
            Logger.log(message: nil, parameterToPrint: successObj)
            exceptionObj.fulfill()
            XCTAssertNotNil(successObj)
        }) { (failureResponse) in
            print(failureResponse)
            exceptionObj.fulfill()
            XCTAssertNil(failureResponse, "received onFailure response.")
        }
        
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
