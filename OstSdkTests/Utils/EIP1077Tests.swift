//
//  EIP1077Tests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 18/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class EIP1077Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func testSoliditySha3() {
        
        if let x = try? Utils.SoliditySha3([["t":"bytes32","v":"0x00"]]) {
            print(x)
            XCTAssertEqual(x, "0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563")
        }
    }
    
    func testEIP() {
        var tx: [String: String] = [:]
        
        tx["from"] = "0x5a85a1E5a749A76dDf378eC2A0a2Ac310ca86Ba8"
        tx["to"] = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx["value"] = "1"
        tx["gasPrice"] = "0"
        tx["gas"] = "0"
        tx["data"] = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx["nonce"] = "1"
        tx["callPrefix"] = "0x"
        
        XCTAssertEqual(try EIP1077(transaction: tx).toEIP1077transactionHash(), "0xc11e96ba445075d92706097a17994b0cc0d991515a40323bf4c0b55cb0eff751")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
