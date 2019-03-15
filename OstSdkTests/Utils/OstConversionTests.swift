//
//  OstConversionTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 15/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk
import BigInt

class OstConversionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConversion() throws {
        let btAmount = try OstConversion.fiatToBt(ostToBtConversionFactor: "500",
                                                  btDecimal: 18,
                                                  ostDecimal: 18, //fix
                                                  fiatAmount: BigInt("1")!,
                                                  pricePoint: "0.027626")
        
        XCTAssertEqual(btAmount, BigInt(18098))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
