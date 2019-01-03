//
//  OSTUserModelRepositoryInsertTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTUserModelRepositoryInsertTests: XCTestCase {
    
    var params: Dictionary<String,Any> = ["id":"1",
                                          "name":"value tobe inserted for id 1",
                                          "parent_id":"2",
                                          "status":"active",
                                          "uts": String(Date.timestamp())
    ]
    var nameText: String = "value tobe inserted for id "
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testInsert() {
        
             OSTUserModelRepository.sharedUser.save(params, success: { (userEntity: OSTUser?) in
                XCTAssertTrue((self.params["id"] as! String).elementsEqual(userEntity?.id ?? ""),"Id not equal")
                XCTAssertTrue((self.params["uts"] as! String).elementsEqual(userEntity?.uts ?? ""),"uts not equal")
                XCTAssertTrue((self.params["name"] as! String).elementsEqual(userEntity?.name ?? ""),"name not equal")
            }, failure: nil)
        
    }
    
    func testInsert1() {
        OSTUserModelRepository.sharedUser.save(params, success: { (userEntity: OSTUser?) in
                XCTAssertTrue((self.params["id"] as! String).elementsEqual(userEntity?.id ?? ""),"Id not equal")
                XCTAssertTrue((self.params["uts"] as! String).elementsEqual(userEntity?.uts ?? ""),"uts not equal")
                XCTAssertTrue((self.params["name"] as! String).elementsEqual(userEntity?.name ?? ""),"name not equal")
            }, failure: nil)
    }
    
    func testInsertAllUsers() {
        var id: String
        var paramDict: [String: [String: Any]] = [:]
        var paramArray: Array<[String: Any]> = []
        var param1 = params
        id = "2"
        param1["id"] = id
        param1["name"] = nameText + id
        paramDict[id] = param1
        paramArray.append(param1)
        var param2 = params
        id = "3"
        param2["id"] = id
        param2["name"] = nameText + id
        paramDict[id] = param2
        paramArray.append(param2)
        
        OSTUserModelRepository.sharedUser.saveAll(paramArray, success: { (userEntities, failuarArray) in
            for userEntity: OSTUser in (userEntities as? Array<OSTUser> ?? []) {
                let param = paramDict[userEntity.id]
                XCTAssertTrue((param!["id"] as! String).elementsEqual(userEntity.id ),"Id not equal")
                XCTAssertTrue((param!["uts"] as! String).elementsEqual(userEntity.uts),"uts not equal")
                XCTAssertTrue((param!["name"] as! String).elementsEqual(userEntity.name ?? ""),"name not equal")
            }
        }, failure: { (error) in
            print("testInsertAllUsersWithBlock :: error : \(error)")
        })
    }

    func testInsertFailed() {
        var paramArray: Array<[String: Any]> = []
        var param1 = params
        param1["id"] = "6"
        param1["address"] = "0x\(param1["id"]!)"
        paramArray.append(param1)
        var param2 = params
        param2["id"] = "7#"
        param2["address"] = "0x\(param2["id"]!)"
        paramArray.append(param2)

        OSTUserModelRepository.sharedUser.saveAll(paramArray, success: { (successArray, failuarArray) in
            XCTAssertFalse(true, "did not received an error")
        }, failure: { (error) in
            XCTAssertTrue(true, "did not received an error")
        })
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
