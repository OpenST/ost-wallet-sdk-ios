//
//  OstTokenDeleteTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstTokenDeleteTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDelete() {
        let id = "1"
        OstTokenRepository.sharedToken.delete(id, success: { (isSuccess) in
            XCTAssertTrue(isSuccess, "Data is not deleted.")
            if isSuccess {
                self.testExistance(id)
            }
        })
        
    }

    
    func testExistance(_ id: String) {
        do {
            let ruleEntity: OstToken? = try OstTokenRepository.sharedToken.get(id)
            XCTAssertNil(ruleEntity, "User entity should be nil")
        }catch {
            XCTAssertTrue(false, "should not receive error")
        }
    }
    
    func testNonExistingDelete() {
        let id = "100000000"
        OstTokenRepository.sharedToken.delete(id, success: { (isSuccess) in
            XCTAssertTrue(isSuccess, "Data is not deleted.")
            if isSuccess {
                self.testExistance(id)
            }
        })
    }
    
    
    func testDeleteAll() {
        OstTokenRepository.sharedToken.deleteAll(["2","3"], success: { (isSuccess) in
            XCTAssertTrue(isSuccess)
        })
    }
    
    func testDeleteWithInvalidId() {
        OstTokenRepository.sharedToken.delete("1#", success: { (isSuccess) in
            XCTAssertFalse(isSuccess)
        })
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
