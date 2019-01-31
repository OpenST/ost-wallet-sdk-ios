//
//  OstSecure.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

struct OstWalletKeys {
    var privateKey: String?
    var publicKey: String?
    var address: String?
    
    init(privateKey: String? = nil, publicKey: String? = nil, address: String? = nil) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.address = address
    }
}


protocol OstCrypto {
    
    func genSCryptKey(salt: Data, n:Int, r:Int, p: Int, size: Int, stringToCalculate: String) throws -> Data
    
    func genHKDFKey(salt saltBytes: [UInt8], data dataBytes: [UInt8]) throws -> [UInt8]
    
    func aesGCMEncrypt(aesKey: [UInt8], iv: [UInt8], ahead: [UInt8], dataToEncrypt: [UInt8]) throws -> [UInt8]
    
    func aesGCMDecrypt(aesKey: [UInt8], iv: [UInt8], ahead: [UInt8]?, dataToDecrypt : [UInt8]) throws -> [UInt8] 
    
    func genDigest(bytes: [UInt8]) -> [UInt8]
    
    func generateCryptoKeys() throws -> OstWalletKeys
    
    func signTx(_ tx: String, withPrivatekey privateKey: String) throws -> String
}
