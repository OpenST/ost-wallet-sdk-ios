////
////  GenosisSafeTests.swift
////  OstSdkTests
////
////  Created by aniket ayachit on 16/02/19.
////  Copyright © 2019 aniket ayachit. All rights reserved.
////
//
//import XCTest
//@testable import OstSdk
//
//class GnosisSafeTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testAddOwnerWithThreshold() {
//        let expectedOutput = "0x0d582f1300000000000000000000000098443ba43e5a55ff9c0ebeddfd1db32d7b1a949a0000000000000000000000000000000000000000000000000000000000000001"
//        XCTAssertEqual(try! GnosisSafe().getAddOwnerWithThresholdExecutableData(abiMethodName: "addOwnerWithThreshold", ownerAddress: "0x98443bA43e5a55fF9c0EbeDdfd1db32d7b1A949A"), expectedOutput)
//    }
//    
//    func testAuthorizeSession() {
//        let expectedOutput = "0x028c979d00000000000000000000000099dbad5becad9eb32eb12a709aaf831d1be3b25500000000000000000000000000000000000000000000000000000000000f4240000000000000000000000000000000000000000000000000000000174876e800"
//        
//        let spendingLimit = "1000000"
//        let expirationHeight = "100000000000"
//        let sessionAddress = "0x99dBAD5BECad9eB32eb12a709aAF831d1BE3b255"
//        
//        XCTAssertEqual(try! GnosisSafe().getAddSessionExecutableData(abiMethodName: "authorizeSession",
//                                                                     sessionAddress: sessionAddress,
//                                                                     expirationHeight: expirationHeight,
//                                                                     spendingLimit: spendingLimit).lowercased(),
//                       expectedOutput)
//    }
//    
//    func testGetSafeTxDataForAuthrozieDevice() throws {
//        let expectedOutput = "0x4fd9d0aed661d3993b562981a1cc2f5670723bab7bb45e3ff0c42fc021fa30b4"
//        let addOwnerExecutableData = "0x0d582f1300000000000000000000000098443ba43e5a55ff9c0ebeddfd1db32d7b1a949a0000000000000000000000000000000000000000000000000000000000000001"
//        let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
//        let typedDataInput = try! GnosisSafe().getSafeTxData(verifyingContract: "0x98443bA43e5a55fF9c0EbeDdfd1db32d7b1A949A",
//                                                             to: "0x98443bA43e5a55fF9c0EbeDdfd1db32d7b1A949A",
//                                                             value: "0",
//                                                             data: addOwnerExecutableData,
//                                                             operation: "0",
//                                                             safeTxGas: "0",
//                                                             dataGas: "0",
//                                                             gasPrice: "0",
//                                                             gasToken: NULL_ADDRESS,
//                                                             refundReceiver: NULL_ADDRESS,
//                                                             nonce: "0")
//        
//        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
//        let signingHash = try! eip712.getEIP712SignHash()
//        
//        XCTAssertEqual(signingHash, expectedOutput)
//    }
//    
//    func testGetSafeTxDataForAuthorizeSession() throws {
//        let expectedOutput = "0x204e19fb7d8f765c487d67f0e77460a24804ef10a12d0fbfa668bb9dc036d83b"
//        let expectedSignature = "0x5acb9578719d998ae6500302bb187187def93cfc0ec57fb8d36b05043519d09721aa3f87dda1795a8ac5a867c5ae315740f00740b8866bb4b23506cb1717a46c1c"
//        
//        let toAddress = "0x59aAF1528a3538752B165EB2D6e0293C86bbCa4F"
//        let NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
//        let verifyingContract = "0xA5936b94619E1f76349B27879c8B54A118c15A82"
//        //0x99cb31ed6a0f634cee503d97fab53dcd5702fb6e3e4630dc9679917e548ccf59
//        let privateKey = "0x99cb31ed6a0f634cee503d97fab53dcd5702fb6e3e4630dc9679917e548ccf59"
//        let callData = "0x028c979d00000000000000000000000099dbad5becad9eb32eb12a709aaf831d1be3b25500000000000000000000000000000000000000000000000000000000000f4240000000000000000000000000000000000000000000000000000000174876e800"
//        
//        let typedDataInput = try GnosisSafe().getSafeTxData(verifyingContract: verifyingContract,
//                                                            to: toAddress,
//                                                            value: "0",
//                                                            data: callData,
//                                                            operation: "0",
//                                                            safeTxGas: "0",
//                                                            dataGas: "0",
//                                                            gasPrice: "0",
//                                                            gasToken: NULL_ADDRESS,
//                                                            refundReceiver: NULL_ADDRESS,
//                                                            nonce: "4")
//        
//        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
//        let signingHash = try! eip712.getEIP712SignHash()
//        
//        let signature = try OstCryptoImpls().signTx(signingHash, withPrivatekey: privateKey)
//        
//        XCTAssertEqual(signingHash.lowercased(), expectedOutput.lowercased())
//        XCTAssertEqual(signature, expectedSignature)
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
