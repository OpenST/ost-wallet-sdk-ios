//
//  GenosisSafeTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class GnosisSafeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddOwnerWithThreshold() throws {
        let expectedOutput = "0x0d582f1300000000000000000000000098443ba43e5a55ff9c0ebeddfd1db32d7b1a949a0000000000000000000000000000000000000000000000000000000000000001"
        XCTAssertEqual(try! GnosisSafe().getAddOwnerWithThresholdExecutableData(ownerAddress: "0x98443bA43e5a55fF9c0EbeDdfd1db32d7b1A949A"), expectedOutput)
    }
    
    func testGetSafeTxData() throws {
        let expectedOutput = "0x4fd9d0aed661d3993b562981a1cc2f5670723bab7bb45e3ff0c42fc021fa30b4"
        let addOwnerExecutableData = "0x0d582f1300000000000000000000000098443ba43e5a55ff9c0ebeddfd1db32d7b1a949a0000000000000000000000000000000000000000000000000000000000000001"
        let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
        let typedDataInput = try! GnosisSafe().getSafeTxData(to: "0x98443bA43e5a55fF9c0EbeDdfd1db32d7b1A949A", value: "0", data: addOwnerExecutableData, operation: "0", safeTxGas: "0", dataGas: "0", gasPrice: "0", gasToken: NULL_ADDRESS, refundReceiver: NULL_ADDRESS, nonce: "0")
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
        let signingHash = try! eip712.getEIP712SignHash()
        
        XCTAssertEqual(signingHash, expectedOutput)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
