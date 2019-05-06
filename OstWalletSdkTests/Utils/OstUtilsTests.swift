/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk
import CryptoSwift

class OstUtilsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQueryString() {
        let nestedObj: [String: Any] = ["c":[["a":"abc","b":"xyz"],["a":"abc","b":"xyz"]]]
        
        var nestedQ: [HttpParam] = []
        _ = OstUtils.buildNestedQuery(params: &nestedQ, paramKeyPrefix: "", paramValObj: nestedObj)
        
        let queryString = nestedQ.map {"\($0.getParamName())=\($0.getParamValue())"}.joined(separator: "&")
        
        XCTAssertNotNil(queryString)
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
        let expectedSignature = "0xabec8b22bd082266fa2cc0df7b0e4a0c2053245f4c153873a877add87be75d9256285fdd990973f18ecc0e83748d2442c8fd67bcf63cf0e3f425741103fe3a351b"
        let resource = "/tokens/"
        
        let params = [
            "c": [
                "c1": [["p21": "a", "p22": "b"], [ "p21": "c", "p22": "d"]],
                "a1": "Hello",
                "b1": 123456,
                "d1": ["Hello","World","OST","PLATFORM"]
            ],
            "b":["Hello","World","OST","PLATFORM"],
            "a":[[ "p2": "b", "p1": "a"], [ "p1": "c", "p2": "d"]],
            "token_id": 58,
            "user_id":"6c6ea645-d86d-4449-8efa-3b54743f83de",
            "wallet_address": "0x60A20Cdf6a21a73Fb89475221D252865C695e302",
            "request_timestamp": "1549449148",
            "api_signer_address":"0xf65c7a49981db56AED34beA4617E32e326ACf977",
            "signature_kind":"OST1-PS",
            ] as [String : Any]
        
        
        //Sign with API-KEY = 0x6edc3804eb9f70b26731447b4e43955c5532f2195a6fe77cbed287dbd3c762ce
        
        let signature = try OstAPISigner(userId: "6c6ea645-d86d-4449-8efa-3b54743f83de").sign(resource: resource, params: params)
        Logger.log(message: "signature", parameterToPrint: signature)
        XCTAssertEqual(signature, expectedSignature)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testToAtto() {
        XCTAssertEqual(OstUtils.toAtto( "0.000000000000000001" ) , "1");
        XCTAssertEqual(OstUtils.toAtto( "0.000000000000000011" ) , "11");
        XCTAssertEqual(OstUtils.toAtto( "1" ) , "1000000000000000000");
        XCTAssertEqual(OstUtils.toAtto( "01" ) , "1000000000000000000");
        XCTAssertEqual(OstUtils.toAtto( "1.1" ) , "1100000000000000000");
        XCTAssertEqual(OstUtils.toAtto( "01.1" ) , "1100000000000000000");
        XCTAssertEqual(OstUtils.toAtto( "1000000000000000" ) , "1000000000000000000000000000000000");
        XCTAssertEqual(OstUtils.toAtto( "1000000000000000.1" ) , "1000000000000000100000000000000000");
    }
    
    func testFromAtto() {
        XCTAssertEqual(OstUtils.fromAtto( "1" ) , "0.000000000000000001");
        XCTAssertEqual(OstUtils.fromAtto( "01" ) , "0.000000000000000001");
        XCTAssertEqual(OstUtils.fromAtto( "11" ) , "0.000000000000000011");
        XCTAssertEqual(OstUtils.fromAtto( "0011" ) , "0.000000000000000011");
        XCTAssertEqual(OstUtils.fromAtto( "1000000000000000000" ) , "1");
        XCTAssertEqual(OstUtils.fromAtto( "1100000000000000000" ) , "1.1");
        XCTAssertEqual(OstUtils.fromAtto( "1000000000000000000000000000000000" ) , "1000000000000000");
        XCTAssertEqual(OstUtils.fromAtto( "1000000000000000100000000000000000" ) , "1000000000000000.1");
    }

}
