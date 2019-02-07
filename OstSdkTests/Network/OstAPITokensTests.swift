//
//  OstTestAPITests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstAPITokensTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    class OstAPIMockToken: OstAPITokens {
        override init() {
            super.init()
            _ = try! OstMockUser(["id":OstMockAPISigner.userId])
        }
        
        override func sign(_ params: inout [String: Any]) throws {
            let (signature, _) =  try OstMockAPISigner(userId: OstUser.currentDevice!.user_id!).sign(resource: getResource, params: params)
            params["signature"] = signature
        }
    }

    func testGetToken() throws {
        let exceptionObj = expectation(description: "Get Token with callback")
         
        try OstAPIMockToken().getToken(success: { (successResponse) in
            Logger.log(message: "successResponse", parameterToPrint: successResponse)
            XCTAssertNotNil(successResponse)
            exceptionObj.fulfill()
        }, failuar: { (failuarResponse) in
            Logger.log(message: "failuar", parameterToPrint: failuarResponse)
            exceptionObj.fulfill()
            XCTAssertNil(failuarResponse, "received failuar response.")
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
