//
//  OSTRuleGetTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OSTRuleGetTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGet() {
        do{
            let id = "2"
            let ruleEntity: OSTRule? = try OSTRuleModelRepository.sharedRule.get(id)
            print(ruleEntity?.name ?? "unknown")
            print("testGetRule :: id :: \(id) :: RuleEntity :: \(ruleEntity?.data ?? [:])")
            XCTAssertEqual(ruleEntity?.id, id, "entity is not same")
        }catch {
            XCTAssertFalse(true, "error is not excepted.")
        }
        testGetInMemory()
    }
    
    func testGetInMemory() {
        do{
            let id = "2"
            let ruleEntity: OSTRule? = try OSTRuleModelRepository.sharedRule.get(id)
            print("testGetRule :: id :: \(id) :: RuleEntity :: \(ruleEntity?.data ?? [:])")
            XCTAssertEqual(ruleEntity?.id, id, "entity is not same")
        }catch {
            XCTAssertFalse(true, "error is not excepted.")
        }
        
    }
    
    func testGetNonExisting() {
        do{
            let id = "10000000"
            let ruleEntity: OSTRule? = try OSTRuleModelRepository.sharedRule.get(id)
            XCTAssertNil(ruleEntity, "ruleEntity shoule be nil")
        }catch {
            XCTAssertFalse(true, "error is not excepted.")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
