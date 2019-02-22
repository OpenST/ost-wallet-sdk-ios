//
//  OstCryptoTests.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import XCTest
@testable import OstSdk

class OstCryptoTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSCrypt() throws {
        let saltData: Data = "salt".data(using: .utf8)!
        let password: String = "Sachin"
        
        let output: String = "22db5466eb082120723a67ebd334ae93796286759e5640b297bd2bd3054cde8a"
        
        let SCryptOutput: Data = try OstCryptoImpls().genSCryptKey(salt: saltData, n: 2, r: 2, p: 2, size: 32, stringToCalculate: password)
        XCTAssertEqual(SCryptOutput.toHexString(), output, "SCrypt output is different")
        
    }
    
    func testHKDF() {
        let saltData: Data = "salt".data(using: .utf8)!
        let password: String = "Sachin"
        let saltUInt = Array(saltData)
        
        let hkdfOutputVal: String = "08418ad8001d0d099fba60a574df6a1debeff1668c9d6998efb2a51c7fe3996a"
        
        do {
            let SCryptOutput: Data = try OstCryptoImpls().genSCryptKey(salt: saltData, n: 2, r: 2, p: 2, size: 32, stringToCalculate: password)
            
            let SCryptOutputUInt: Array<UInt8> = Array(SCryptOutput)
            let hkdfOutput: [UInt8] = try OstCryptoImpls().genHKDFKey(salt: saltUInt, data: SCryptOutputUInt)
            
            XCTAssertTrue(hkdfOutput.toHexString() == hkdfOutputVal, "hkdf output is different")
        }catch let error {
            XCTAssertNil(error, "Error should not occure")
        }
    }
    
    func testDigest() {
        let digestOutputVal = "6dfe2e5b192dd048a652f1bca2b115055b98426e104814deaa8b4d74506fcca3"
        let digestOutput = OstCryptoImpls().genDigest(bytes: Array("Aniket".utf8))
        XCTAssertTrue(digestOutputVal == digestOutput.toHexString() , "digest output is different")
    }
    
    func testAESEncryption() throws{
        let val = String(Date.negativeTimestamp())
        
        let SCryptOutput: Data = try OstCryptoImpls().genSCryptKey(salt: val.data(using: .utf8)!, n: 2, r: 2, p: 2, size: 32, stringToCalculate: "a")
        let encryptedData: [UInt8] = try OstCryptoImpls().aesGCMEncrypt(aesKey: Array(SCryptOutput), iv: Array("iv".utf8), ahead: Array("ahead".utf8), dataToEncrypt: Array("Aniket".utf8))
        
        let decryptedData = try OstCryptoImpls().aesGCMDecrypt(aesKey: Array(val.utf8), iv: Array("iv".utf8), ahead: nil, dataToDecrypt: encryptedData)
        let decryptedString = String(bytes: decryptedData, encoding: .utf8)
        
        XCTAssertEqual(decryptedString, "Aniket")
    }
    
    func testGenerateCryptoKeys() {
        let expectedSignedTx = "0x34daffa295320477d88e6b9597f97cd3a852de50fc471a6b39a5525a2b00459d47d43367f48d24ac9f8f986bb0b4e1b349eb7ab9dc028a4f5d0d2f0909acd5611c"
        do {
            let OstCrypto = OstCryptoImpls()
            let walletKeys = try OstCrypto.generateCryptoKeys()
            let txHash = getEIP1077TxHash()
            XCTAssertEqual(txHash, "0xc11e96ba445075d92706097a17994b0cc0d991515a40323bf4c0b55cb0eff751")
            let signedTx = try OstCrypto.signTx(txHash, withPrivatekey: walletKeys.privateKey!)
            XCTAssertEqual(expectedSignedTx, signedTx)
        }catch let error {
            XCTAssertNil(error, "error should be nil")
        }
    }
    
    func testGenerateRecoveryKey() throws {
        let expectedRecoveryAddress = "0x6bb02bba5beda4cfb33aa3a3e39f861bb12a0fd7"
        
        let pinPrefix = "steel polar replace claw crew fever winter dragon excess sick possible cry"
        let pin = "123456"
        let pinPostFix = "d54ef261-a1e3-409a-85bd-6b856e8a2098"
        let salt = "8902a8e658b6-db58-a904-3e1a-162fe45d"
        
        let recoveryAddress = try OstCryptoImpls().generateRecoveryKey(pinPrefix: pinPrefix,
                                                                       pin: pin,
                                                                       pinPostFix: pinPostFix,
                                                                       salt: salt, n: 2, r: 2, p: 2, size: 32)
        
        let recoveryAddressRepeat = try OstCryptoImpls().generateRecoveryKey(pinPrefix: pinPrefix,
                                                                             pin: pin,
                                                                             pinPostFix: pinPostFix,
                                                                             salt: salt, n: 2, r: 2, p: 2, size: 32)
        
        XCTAssertEqual(recoveryAddressRepeat, recoveryAddress)
        XCTAssertEqual(expectedRecoveryAddress, recoveryAddressRepeat.lowercased())
        XCTAssertEqual(expectedRecoveryAddress, recoveryAddress.lowercased())
    }
    
    func getEIP1077TxHash() -> String {
        var tx: [String: String] = [:]
        
        tx["from"] = "0x5a85a1E5a749A76dDf378eC2A0a2Ac310ca86Ba8"
        tx["to"] = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx["value"] = "1"
        tx["gasPrice"] = "0"
        tx["gas"] = "0"
        tx["data"] = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx["nonce"] = "1"
        tx["callPrefix"] = "0x"
        
        do {
            let eip1077TxHash = try EIP1077(transaction: tx).toEIP1077transactionHash()
            return eip1077TxHash
        }catch {
            return ""
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
