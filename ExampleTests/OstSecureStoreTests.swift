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

class OstSecureStoreTests: XCTestCase {

    let secureStoreObj = OstSecureStoreImpls(userId: "123-123")
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetEthMetaMapping() throws {
        let metaMappingK = OstEthMetaMapping(address: "0xethAddressForKey", identifier: "secureEnclaveId")
        XCTAssertNoThrow( try secureStoreObj.setEthKeyMappingData(metaMappingK) )
        
        let metaMappingM = OstEthMetaMapping(address: "0xethAddressForMnenonics", identifier: "secureEnclaveId")
        XCTAssertNoThrow( try secureStoreObj.setEthKeyMnenonicsMetaMapping(metaMappingM) )
    }
    
    
    func testGetEthMetaMappingForWrongKey() {
        let mappingK = secureStoreObj.getEthKeyMappingData(forAddress: "0xethAddressForKey")
        XCTAssertNotNil(mappingK)
        
        let mappingM = secureStoreObj.getEthKeyMnenonicsMetaMapping(forAddress: "0xethAddressForMnenonics")
        XCTAssertNotNil(mappingM)
        
        XCTAssertNil(secureStoreObj.getEthKeyMappingData(forAddress: "0xunknownAddress"))
        
        XCTAssertNil(secureStoreObj.getEthKeyMnenonicsMetaMapping(forAddress: "0xunknownAddress"))
        
        XCTAssertNil(secureStoreObj.getEthKeyMappingData(forAddress: "0xethAddressForMnenonics"))
        
        XCTAssertNil(secureStoreObj.getEthKeyMnenonicsMetaMapping(forAddress: "0xethAddressForKey"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
