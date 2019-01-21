////
////  OstKeyDatabase.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 08/01/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class OstKeyDatabase: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testKeyDatabase() {
//        OstSecureKeyRepository.sharedSecureKey.save(["key":"0x123","data":"A".data(using: .utf8)!], success: { (secureKey) in
//            print(secureKey!)
//        }, failure: { (error) in
//            print(error)
//        })
//    }
//    
//    func testA() {
//        do {
//            try OstInitialDeviceProvisioning(OstKeyGenerationParams()).perform()
//        }catch {
//            
//        }
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
