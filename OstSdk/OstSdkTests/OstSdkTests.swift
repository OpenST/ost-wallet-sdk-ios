//
//  OstSdkTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 29/11/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstSdkTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        do {
            _ = try OstSecureStoreImpls(address: "0x123")
        }catch let error{
            XCTAssertNil(error)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
