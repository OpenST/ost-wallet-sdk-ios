//
//  OstKeychainHelperTests.swift
//  ExampleTests
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import Example
import OstSdk

class OstKeychainHelperTests: XCTestCase {

    let keychianHelper: OstKeychainHelper = OstKeychainHelper(service: "com.ost.test")
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSaveValuesInKeychain() throws {
        XCTAssertNoThrow(try keychianHelper.hardSet(data: "KeyData".data(using: .utf8)!, forKey: "settingKeyData"),
                         "storing should not throw error")
        XCTAssertNoThrow(try keychianHelper.set(string: "KeyString", forKey: "settingkeyString"), "storing should not throw error")
    }
    
    func testGetValuesFromKeychain() {
        let data: Data? = keychianHelper.get(forKey: "settingKeyData")
        XCTAssertNotNil(data)
        XCTAssertEqual(data, "KeyData".data(using: .utf8)!)
        
        let string: String? = keychianHelper.get(forKey: "settingkeyString")
        XCTAssertNotNil(string)
        XCTAssertEqual(string, "KeyString")
    }
    
    func testDeleteValuesFromKeychain() throws {
        try keychianHelper.delete(forKey: "settingKeyData")
        let data: Data? = keychianHelper.get(forKey: "settingKeyData")
        XCTAssertNil(data)
        
         XCTAssertThrowsError(try keychianHelper.delete(forKey: "deleteNonExistantValue")) 
    }
    
    func testKeychainGetFail() {
        let value: String? = keychianHelper.get(forKey: "getNonExistingValue")
        XCTAssertNil(value)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
