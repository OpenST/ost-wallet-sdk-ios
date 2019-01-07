//
//  OSTSecureStoreTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTSecureStoreTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncryptData() {
        let text = "Aniket"
        
        do {
            let encData = try OSTSecureStoreImpls(address: "0x123").encrypt(data: text.data(using: .utf8)!)
            print(encData?.toHexString())
        }catch let error{
            print(error)
            XCTAssertFalse(true,"error should not receive")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
