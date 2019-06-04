/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import XCTest
@testable import OstWalletSdk

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
        
        if let x = try? SoliditySha3.getHash([["t":"bytes32","v":"0x00"]]) {
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
        tx["callPrefix"] = "0x0"
        
        XCTAssertEqual(try EIP1077(transaction: tx).toEIP1077transactionHash(), "0xc11e96ba445075d92706097a17994b0cc0d991515a40323bf4c0b55cb0eff751")
    }
    
    func testCallPrefix() throws {

        let string = "executeRule(address,bytes,uint256,bytes32,bytes32,uint8)"
        let soliditySha3 = try SoliditySha3.getHash(string)
        XCTAssertEqual(soliditySha3.substr(0, 10), "0x97ebe030")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
