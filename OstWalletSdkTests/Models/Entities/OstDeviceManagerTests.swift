/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk

class OstDeviceManagerTests: XCTestCase {
   
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

    func testInitEntity() throws {
        XCTAssertNotNil(try OstDeviceManager.storeEntity(multiSigJSON), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let multiSig: OstDeviceManager? = try OstDeviceManagerRepository.sharedDeviceManager.getById("0x...") as? OstDeviceManager
        XCTAssertNotNil(multiSig, "entity should not be nil")
        XCTAssertEqual(multiSig?.address, multiSigJSON["address"] as? String, "address is not same")
    }
    
    func testUpdateEntity() throws {
        multiSigJSON["nonce"] = 2
        multiSigJSON["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstDeviceManager.storeEntity(multiSigJSON), "Entity should not be nil")
        let multiSig: OstDeviceManager? = try OstDeviceManagerRepository.sharedDeviceManager.getById("0x...") as? OstDeviceManager
        XCTAssertNotNil(multiSig, "entity should not be nil")
        XCTAssertEqual(multiSig?.nonce, multiSigJSON["nonce"] as? Int, "address is not same")
    }
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
