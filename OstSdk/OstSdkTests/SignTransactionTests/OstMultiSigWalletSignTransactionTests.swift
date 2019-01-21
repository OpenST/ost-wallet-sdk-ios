//
//  OstMultiSigWalletSignTransactionTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 14/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstMultiSigWalletSignTransactionTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMultiSigSignTransaction() {
        
        
    }
    
    func testInitUser() {
        //create user
        do {
            let userDict = ["id": 1,
                            "token_holder_id": 1,
                            "multisig_id": 1,
                            "economy_id" : 1,
                            "uts" : Date.timestamp()]
            let user = try OstSdk.initUser(userDict)
            XCTAssertNotNil(user, "user object should not be nil")
        }catch let error {
            print(error)
            XCTAssertNil(error, "error should be nil")
        }
        
    }
    
    func testKeyGenerationProcess() {
        do {
            let wallet =  try OstKeyGenerationProcess().perform()
            print(wallet.address!)
            print(wallet.privateKey!)
            print(wallet.publicKey!)
        }catch let error{
            print(error)
        }
    }
    
    func testInitMultiSig() {
        do {
            let multiSig: [String: Any] = ["id":1,
                                           "user_id": 1,
                                           "address": "0x123",
                                           "token_holder_id": 1,
                                           "wallets": [1,2,3],
                                           "requirement": 1,
                                           "authorize_session_callprefix": "0x",
                                           "uts" : Date.timestamp()]
            try OstSdk.initMultiSig(multiSig)
        }catch let error {
            print(error)
            XCTAssertNil(error, "error should be nil")
        }
    }
    
    func testInitMultiSigWallet() {
        do {
            let multiSigWallet: [String: Any] = ["id": 1,
                                                 "local_entity_id": -1,
                                                 "address": "0x123a",
                                                 "multi_sig_id": "1",
                                                 "nonce": "0",
                                                 "status": "CREATED",
                                                 "uts" : Date.timestamp()]
           try OstSdk.initMultiSigWallet(multiSigWallet)
        }catch let error {
            print(error)
            XCTAssertNil(error, "error should be nil")
        }
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
