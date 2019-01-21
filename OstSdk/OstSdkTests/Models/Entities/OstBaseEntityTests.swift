//
//  OstBaseEntityTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstBaseEntityTests: XCTestCase {
    
    
    var jsonData: [String: Any] = ["id":"123","parent_id":"1","status":"active","uts": "12324","name": "Aniket"]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitObj() {
        
        XCTAssertNotNil(try OstUser(jsonData), "Object creation failed.")
        XCTAssertNotNil(try OstUser(["id":1]), "Object creation failed.")
    }
    
    func createObjCreationForTrueCase(json: [String: Any]) {
        XCTAssertNotNil(try! OstUser(json), "Entity object should not be nil")
    }
    
    func createObjCreationForFalseCase(json: [String: Any]) {
        XCTAssertThrowsError(try OstUser(json))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
