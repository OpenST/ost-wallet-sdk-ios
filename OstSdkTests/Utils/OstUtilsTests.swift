//
//  OstUtilsTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstUtilsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuildNestedQuery() throws {
        let expectedQueryString = "a=1&b[]=2&b[]=3&c[d]=5&c[e]=4&c[f][]=1&c[f][]=2"
        let nestedObj: [String: Any] = ["a": 1,
                                        "b": [2,3],
                                        "c": ["f": [1,2],
                                              "e": 4,
                                              "d": 5
            ]
        ]
        var nestedQ: [HttpParam] = []
        _ = OstUtils.buildNestedQuery(params: &nestedQ, paramKeyPrefix: "", paramValObj: nestedObj)
        
        let queryString = nestedQ.map {"\($0.getParamName())=\($0.getParamValue())"}.joined(separator: "&")
        
        XCTAssertEqual(queryString, expectedQueryString)
    }
    
    func testSignature() throws {
        let expectedSignature = "0x38678235319123c47040aa1de8590ee5fe5e16ecffdd1f0dd4098ca716a6bfd660fa5e232e30d41e5b05e3b118b37d5388f4f8dd60323fe1be7b43fc8203538c1c"
        let resource = "/tokens/"
        let params: [String: Any] = ["token_id": 58,
                                     "user_id":"bcffc567-2881-4610-aa86-fa89f37bc197",
                                     "wallet_address": "0x60A20Cdf6a21a73Fb89475221D252865C695e302",
                                     "request_timestamp": "1549294289",
                                     "personal_sign_address":"0xf65c7a49981db56AED34beA4617E32e326ACf977",
                                     "signature_kind":"OST1-PS"]
        
        let (signature, _) = try OstMockAPISigner(userId: OstMockAPISigner.userId).sign(resource: resource, params: params)
        
        XCTAssertEqual(signature, expectedSignature)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
