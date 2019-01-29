//
//  OstDeviceManagerEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 29/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstDeviceManagerEntityTests: XCTestCase {
   
    var multiSigJSON =  ["user_id": "1a",
                     "address": "0x...",
                     "requirement": "1",
                     "nonce": "",
                     "updated_timestamp": 12344,
                     "status": "Activated"] as [String : Any]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitMultiSig() throws {
        XCTAssertNotNil(try OstDeviceManager.parse(multiSigJSON), "Entity should not be nil")
    }
    
    func testGetMultiSig() throws {
        let multiSig: OstDeviceManager? = try OstDeviceManagerRepository.sharedDeviceManager.getById("1a") as? OstDeviceManager
        XCTAssertNotNil(multiSig, "entity should not be nil")
        XCTAssertEqual(multiSig?.address, multiSigJSON["address"] as? String, "address is not same")
    }
    
    func testUpdateMultiSig() throws {
        multiSigJSON["address"] = "0x1..."
        multiSigJSON["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstDeviceManager.parse(multiSigJSON), "Entity should not be nil")
        let multiSig: OstDeviceManager? = try OstDeviceManagerRepository.sharedDeviceManager.getById("1a") as? OstDeviceManager
        XCTAssertNotNil(multiSig, "entity should not be nil")
        XCTAssertEqual(multiSig?.address, multiSigJSON["address"] as? String, "address is not same")
    }
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
