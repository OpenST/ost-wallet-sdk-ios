//
//  OstUserEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstUserTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitUser() throws {
        let id = "1"
        let userDict = ["id": "\(id)a",
            "token_holder_id": "\(id)a",
            "multisig_id": "\(id)a",
            "economy_id" : "\(id)a",
            "updated_timestamp" : Date.timestamp()] as [String : Any]


         try OstUser.storeEntity(userDict)
        let user: OstUser? = try OstUser.getById(userDict["id"] as! String)
        print(user ?? "")
        XCTAssertNotNil(user, "user should not be nil")
        XCTAssertEqual(user?.id, userDict["id"] as? String, "id is not equal")
    }
    
    func testBulkInitUser() throws {
        for i in 2..<5 {
            let id = i
            let userDict = ["id": "\(id)a",
                "token_holder_id": "\(id)a",
                "multisig_id": "\(id)a",
                "economy_id" : "\(id)a",
                "updated_timestamp" : Date.timestamp()] as [String : Any]
            
            try OstUser.storeEntity(userDict)
            let user: OstUser? = try OstUser.getById(userDict["id"] as! String)
            print(user ?? "")
            XCTAssertNotNil(user, "user should not be nil")
            XCTAssertEqual(user?.id, userDict["id"] as? String, "id is not equal")
        }
    }
    
    func testGetEntity() {
        do {
            let user: OstUser? = try OstUser.getById("1a")
            XCTAssertNil(user)
            let user1: OstUser? = try OstUser.getById("4a")
            XCTAssertNotNil(user1)
        }catch let error{
            print(error)
        }
    }
   
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
