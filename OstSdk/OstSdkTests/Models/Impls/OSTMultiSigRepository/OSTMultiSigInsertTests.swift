//
//  OSTMultiSigInsertTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTMultiSigInsertTests: XCTestCase {
    let defaultAddress = "0x123"
    var params: Dictionary<String,Any> =  ["id": "1",
                                           "user_id": "{user_id}",
                                           "address": "0x123",
                                           "token_holder_id": "123",
                                           "wallets": ["123","123"],
                                           "requirement": "1",
                                           "authorize_session_callprefix": "0x1234",
                                           "uts": Date.negativeTimestamp()]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsertMultiSig() {
        
        OSTMultiSigRepository.sharedMultiSig.save(params, success: { (entity: OSTMultiSig?) in
            XCTAssertEqual((self.params["id"] as! String), entity?.id ?? "", "Id not equal")
            XCTAssertEqual((self.params["uts"] as! String), entity?.uts ?? "", "uts not equal")
            XCTAssertEqual((self.params["address"] as! String), entity?.address ?? "", "uts not equal")
        }, failure: { error in
            print(error)
            XCTAssertNil(error, "Error should be nil")
        })
    }
    
    func testInsert1MultiSig() {
        OSTMultiSigRepository.sharedMultiSig.save(params, success: { (entity: OSTMultiSig?) in
            XCTAssertEqual((self.params["id"] as! String), entity?.id ?? "", "Id not equal")
            XCTAssertEqual((self.params["uts"] as! String), entity?.uts ?? "", "uts not equal")
            XCTAssertEqual((self.params["address"] as! String), entity?.address ?? "", "uts not equal")
        }, failure: nil)
    }
    
    func testInsertAllMultiSig() {
        var id: String
        var paramDict: [String: [String: Any]] = [:]
        var paramArray: Array<[String: Any]> = []
        var param1 = params
        id = "2"
        param1["id"] = id
        param1["address"] = defaultAddress+id
        paramDict[id] = param1
        paramArray.append(param1)
        var param2 = params
        id = "3"
        param2["id"] = id
        param2["address"] = defaultAddress+id
        paramDict[id] = param2
        paramArray.append(param2)
        
        OSTMultiSigRepository.sharedMultiSig.saveAll(paramArray, success: { (entities, failuarArray) in
            for entity: OSTMultiSig in (entities as? Array<OSTMultiSig> ?? []) {
                let param = paramDict[entity.id]!
                XCTAssertEqual((param["id"] as! String), entity.id, "not equal")
                XCTAssertEqual(String(param["uts"] as! Int), String(entity.uts) , "uts not equal")
                XCTAssertEqual((param["address"] as! String), entity.address ?? "", "address not equal")
            }
        }, failure: { (error) in
            print("testInsertAllUsersWithBlock :: error : \(error)")
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
