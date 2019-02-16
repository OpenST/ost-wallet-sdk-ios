//
//  GenosisSafeTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class GenosisSafeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenosisSafe() throws {
        try GenosisSafe().getAddOwnerWithThresholdExecutableData(ownerAddress: "0x98443ba43e5a55ff9c0ebeddfd1db32d7b1a949a")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
