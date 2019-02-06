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
        let expectedSignature = "0x208cb2460144e85a098e91eef88954cca56b2b29cbd65314ac220091aa9daf8713a49aed77d5e3785cc4923d975e7e2bb79c3021baf728dfd790080f954d09331b"
        let resource = "/tokens/"
        
        let params: [String: Any] = ["token_id": 58,
                                     "user_id":"6c6ea645-d86d-4449-8efa-3b54743f83de",
                                     "wallet_address": "0x60A20Cdf6a21a73Fb89475221D252865C695e302",
                                     "request_timestamp": "1549449148",
                                     "api_signer_address":"0xf65c7a49981db56AED34beA4617E32e326ACf977",
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
