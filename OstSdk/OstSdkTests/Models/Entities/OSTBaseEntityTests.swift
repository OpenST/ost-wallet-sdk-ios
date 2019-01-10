//
//  OSTBaseEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTBaseEntityTests: XCTestCase {
    
    let ostBaseEntity = OSTBaseEntity()
    var jsonData: [String: Any] = ["id":"123","parent_id":"1","status":"active","uts": "12324","name": "Aniket"]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitObj() {
        XCTAssertNotNil(ostBaseEntity)
        XCTAssertNotNil(try OSTUser(jsonData: jsonData), "Object creation failed.")
        XCTAssertNotNil(try OSTUser(jsonData: ["id":1]), "Object creation failed.")
    }
    
    //MARK: - Test ID
//    func testID(){
//        //true cases
//        jsonData["id"] = "123"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = "123abc"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = "123ABC"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = "-123Negative"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = "ABC123sadfde32"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = 123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["id"] = -123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        //false cases
//        jsonData["id"] = "123#"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = ""
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = "123 "
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = "123 acv$"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = ["a","b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = ["a":"b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["id"] = nil
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["idd"] = "123"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//    }
//
//    func testParentId(){
//        //true cases
//        jsonData["parent_id"] = "123"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = "-123"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = "123a"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = "-123a"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = 123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = -123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = ""
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_id"] = nil
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["parent_idd"] = "1"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        //false cases
//        jsonData["parent_id"] = "123!"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["parent_id"] = "123a!"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["parent_id"] = "123 fwe"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["parent_id"] = ["a", "b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["parent_id"] = ["a" : 1]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//    }
//
//    func testStatus(){
//        //true cases
//        jsonData["status"] = "active"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["status"] = "ACTIVE"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["status"] = "ACTive"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["status"] = ""
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["status"] = nil
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        //false cases
//        jsonData["status"] = "activee"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["status"] = 123
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["status"] = -123
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["status"] = ["a":"b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//    }
//
//    func testUTS(){
//        //true cases
//        jsonData["uts"] = "123"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["uts"] = "-123"
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["uts"] = 123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["uts"] = -123
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        jsonData["uts"] = nil
//        XCTAssertTrue(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForTrueCase(json: jsonData)
//
//        //false cases
//        jsonData["uts"] = "123a"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["uts"] = "123 a"
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["uts"] = ""
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["uts"] = ["a","b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//
//        jsonData["uts"] = ["a": "b"]
//        XCTAssertFalse(ostBaseEntity.validJSON(jsonData), "JSON validation failed")
//        createObjCreationForFalseCase(json: jsonData)
//    }
    
    func createObjCreationForTrueCase(json: [String: Any]) {
        XCTAssertNotNil(try! OSTUser(jsonData: json), "Entity object should not be nil")
    }
    
    func createObjCreationForFalseCase(json: [String: Any]) {
        XCTAssertThrowsError(try OSTUser(jsonData: json))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
