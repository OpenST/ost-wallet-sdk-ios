//
//  OstUserEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstUserEntityTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitUser() {
        let id = "4"
        let userDict = ["id": "\(id)a",
            "token_holder_id": "\(id)a",
            "multisig_id": "\(id)a",
            "economy_id" : "\(id)a",
            "uts" : "\(id)a"] as [String : Any]
        
        do {
            let user: OstUser? = try OstSdk.initUser(userDict)
            print(user ?? "")
        }catch let error{
            print(error)
        }
    }
    
    func testGetUser() {
        do {
            let user: OstUser = try OstUserModelRepository.sharedUser.getById("1a") as! OstUser
            print(user)
            let user1: OstUser = try OstUserModelRepository.sharedUser.getById("1a") as! OstUser
            print(user1)
        }catch let error{
            print(error)
        }
    }
    
    func testDeleteUser() {
        do {
            let _ = try OstUserModelRepository.sharedUser.getById("2a") as! OstUser
            OstUserModelRepository.sharedUser.deleteForId("2a")
            let _ = try OstUserModelRepository.sharedUser.getById("2a") as! OstUser
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
