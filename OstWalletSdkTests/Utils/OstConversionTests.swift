/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk
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
