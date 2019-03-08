//
//  OstTransactionTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstTransactionTests: XCTestCase {

    var JSONObject =
    [
        "id": "123",
        "transaction_hash": "0xksjagjkd...",
        "gas_price": 24000,
        "gas_used": 12000,
        "transaction_fee": 9000,
        "status": "CREATED/QUEUED/SUBMITTED/SUCCESS/FAIL",
        "updated_timestamp": "123...",
        "block_timestamp": "...",
        "block_number": 123,
        "rule_name": "approve",
        "transfers": [
            [
                "from": "afda",
                "to": "fadsf",
                "amount": 123124,
                "kind": "credit"
            ]
        ]
    ] as [String : Any]
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEntity() throws {
        XCTAssertNotNil(try OstTransaction.storeEntity(JSONObject), "Entity should not be nil")
    }
    
    func testGetEntity() throws {
        let entity: OstTransaction? = try OstTransactionRepository.sharedTransaction.getById(JSONObject["transaction_hash"] as! String) as? OstTransaction
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.id, JSONObject["transaction_hash"] as? String, "address is not same")
        XCTAssertEqual(entity?.gasPrice, JSONObject["gas_price"] as? Int, "address is not same")
    }
    
    func testUpdateEntity() throws {
        JSONObject["gas_price"] = 10000001
        JSONObject["updated_timestamp"] = Date.timestamp()
        XCTAssertNotNil(try OstTransaction.storeEntity(JSONObject), "Entity should not be nil")
        let entity: OstTransaction? = try OstTransactionRepository.sharedTransaction.getById(JSONObject["transaction_hash"] as! String) as? OstTransaction
        XCTAssertNotNil(entity, "entity should not be nil")
        XCTAssertEqual(entity?.updatedTimestamp, JSONObject["updated_timestamp"] as? TimeInterval, "address is not same")
        XCTAssertEqual(entity?.gasPrice, JSONObject["gas_price"] as? Int, "address is not same")
    }

    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
