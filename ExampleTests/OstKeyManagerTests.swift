//
//  OstSecureStoreTests.swift
//  ExampleTests
//
//  Created by aniket ayachit on 01/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import Example
import OstSdk

class OstKeyManagerTests: XCTestCase {

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateKeyWithMnemonics() throws  {
        let keyManagerObj = try OstKeyManager(userId: "123-1234")
        
        let address: String = try keyManagerObj.createKeyWithMnemonics()
        let mnemonics: [String]? = try keyManagerObj.getMnemonics(forAddresss: address)
        XCTAssertNotNil(mnemonics, "mnemonics should not be nil")

        let ethereumKey: String? = try keyManagerObj.getEthereumKey(forAddresss: address)
        XCTAssertNotNil(ethereumKey, "ethereumKey should not be nil")

        let apiAddress: String? = keyManagerObj.getAPIAddress()
        XCTAssertNotNil(apiAddress)

        let apiPrivateKey: String? = try keyManagerObj.getAPIKey()
        XCTAssertNotNil(apiPrivateKey)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
