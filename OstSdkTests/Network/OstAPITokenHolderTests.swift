//
//  OstAPITokenHolderTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstAPITokenHolderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    class OstAPIMockTokenHolder: OstAPITokenHolder{
        
        override init(userId: String) {
            super.init(userId: userId)
            _ = try! OstMockUser(["id":OstMockAPISigner.userId])
        }
        
        override func sign(_ params: inout [String: Any]) throws {
            let (signature, _) =  try OstMockAPISigner(userId: OstUser.currentDevice!.user_id!).sign(resource: getResource, params: params)
            params["signature"] = signature
        }
    }

    func testDelpoyTokenHolder() throws {
        let exceptionObj = expectation(description: "deploy Token holder with callback")
        
        let params:[String: Any] = ["session_addresses":["0x60A20Cdf6a21a73Fb89475221D252865C695e302",
                                                         "0x60A20Cdf6a21a73Fb89475221D252865C695e302"],
                                    "expiration_height": "123453241",
                                    "spending_limit": "12431"
                                    ]
        
        try OstAPIMockTokenHolder(userId: OstMockAPISigner.userId).deployTokeHolder(params: params, success: { (successResponse) in
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
