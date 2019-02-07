//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by aniket ayachit on 07/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import Example

class ExampleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAPI() {
        MappyUser().getUser(userId: "5c5ad125a5c9b42506d50366", success: { (successObj) in
            XCTAssertNotNil(successObj)
        }) {
            
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
