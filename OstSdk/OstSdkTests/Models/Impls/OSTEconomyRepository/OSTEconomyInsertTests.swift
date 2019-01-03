//
//  OSTEconomyInsertTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTEconomyInsertTests: XCTestCase {
    var params: Dictionary<String,Any> =  ["id": "1",
                                           "uts": Date.negativeTimestamp()
    ]
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() {
        
        OSTEconomyRepository.sharedEconomy.save(params, success: { (entity: OSTEconomy?) in
            XCTAssertEqual((self.params["id"] as! String), entity?.id ?? "", "Id not equal")
            XCTAssertEqual((self.params["uts"] as! String), entity?.uts ?? "", "uts not equal")
        }, failure: { error in
            print(error)
            XCTAssertNil(error, "Error should be nil")
        })
    }
    
    func testInsert1() {
        OSTEconomyRepository.sharedEconomy.save(params, success: { (entity: OSTEconomy?) in
            XCTAssertEqual((self.params["id"] as! String), entity?.id ?? "", "Id not equal")
            XCTAssertEqual((self.params["uts"] as! String), entity?.uts ?? "", "uts not equal")
        }, failure: nil)
    }
    
    func testInsertAllUsers() {
        var id: String
        var paramDict: [String: [String: Any]] = [:]
        var paramArray: Array<[String: Any]> = []
        var param1 = params
        id = "2"
        param1["id"] = id
        paramDict[id] = param1
        paramArray.append(param1)
        var param2 = params
        id = "3"
        param2["id"] = id
        paramDict[id] = param2
        paramArray.append(param2)
        
        OSTEconomyRepository.sharedEconomy.saveAll(paramArray, success: { (entities, failuarArray) in
            for entity: OSTEconomy in (entities as? Array<OSTEconomy> ?? []) {
                let param = paramDict[entity.id]!
                XCTAssertEqual((param["id"] as! String), entity.id, "not equal")
                XCTAssertEqual(String(param["uts"] as! Int), String(entity.uts) , "uts not equal")
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
