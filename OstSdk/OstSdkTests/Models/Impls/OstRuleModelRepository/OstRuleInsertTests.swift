////
////  OstRuleInsert.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 03/01/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstRuleInsert: XCTestCase {
//    
//    var params: Dictionary<String,Any> =  ["id": "1",
//                                           "token_id": "1234",
//                                           "name": "value tobe inserted for id 1",
//                                           "address": "0x123",
//                                           "abi": "JSON_STRING_NEEDS_PARSING",
//                                           "uts": Date.negativeTimestamp()
//                                          ]
//    var nameText: String = "value tobe inserted for id "
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testInsert() {
//        
//        OstRuleModelRepository.sharedRule.save(params, success: { (ruleEntity: OstRule?) in
//            XCTAssertEqual((self.params["id"] as! String), ruleEntity?.id ?? "", "Id not equal")
////            XCTAssertEqual((self.params["uts"] as! String), ruleEntity?.uts ?? "", "uts not equal")
//            XCTAssertEqual((self.params["name"] as! String), ruleEntity?.name ?? "", "name not equal")
//        }, failure: { error in
//            print(error)
//            XCTAssertNil(error, "Error should be nil")
//        })
//    }
//    
//    func testInsert1() {
//        OstRuleModelRepository.sharedRule.save(params, success: { (ruleEntity: OstRule?) in
//            XCTAssertEqual((self.params["id"] as! String), ruleEntity?.id ?? "", "Id not equal")
////            XCTAssertEqual((self.params["uts"] as! String), ruleEntity?.uts ?? "", "uts not equal")
//            XCTAssertEqual((self.params["name"] as! String), ruleEntity?.name ?? "", "name not equal")
//        }, failure: nil)
//    }
//    
//    func testInsertAllUsers() {
//        var id: String
//        var paramDict: [String: [String: Any]] = [:]
//        var paramArray: Array<[String: Any]> = []
//        var param1 = params
//        id = "2"
//        param1["id"] = id
//        param1["name"] = nameText + id
//        paramDict[id] = param1
//        paramArray.append(param1)
//        var param2 = params
//        id = "3"
//        param2["id"] = id
//        param2["name"] = nameText + id
//        paramDict[id] = param2
//        paramArray.append(param2)
//        
//        OstRuleModelRepository.sharedRule.saveAll(paramArray, success: { (ruleEntities, failuarArray) in
//            for ruleEntity: OstRule in (ruleEntities as? Array<OstRule> ?? []) {
//                let param = paramDict[ruleEntity.id]!
//                XCTAssertEqual((param["id"] as! String), ruleEntity.id, "not equal")
////                XCTAssertEqual(String(param["uts"] as! Int), String(ruleEntity.uts) , "uts not equal")
//                XCTAssertEqual((param["name"] as! String), ruleEntity.name, "name not equal")
//            }
//        }, failure: { (error) in
//            print("testInsertAllUsersWithBlock :: error : \(error)")
//        })
//    }
//    
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
