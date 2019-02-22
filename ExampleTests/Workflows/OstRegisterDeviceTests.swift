//
//  OstRegisterDeviceTests.swift
//  ExampleTests
//
//  Created by aniket ayachit on 04/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import Example
import OstSdk

class OstRegisterDeviceTests: XCTestCase {

    var registerDevice: RegisterDevice? = nil
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    class RegisterDevice: OstWorkFlowCallbackImplementation {
        
        var callback: (() -> Void)? = nil
        init(callback: @escaping (() -> Void)) {
            self.callback = callback
        }
        override init(mappyUserId: String) {
            self.mappyUserId = mappyUserId
        }
        
        override func registerDevice(_ apiParams: [String : Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol) {
            callback?()
        }
    }
    
    func testRegisterDeviceVanillaFlow() throws {
        let expectation1 = expectation(description: "SomethingWithDelegate calls the delegate as the result of an async method completion")
        
        registerDevice = RegisterDevice(callback: {
            expectation1.fulfill()
        })
        try OstSdk.setupDevice(userId: "12", tokenId: "58", delegate: registerDevice!)
        
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
