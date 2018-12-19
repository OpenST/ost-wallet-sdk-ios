//
//  OSTCryptoImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift

class OSTCryptoImpls: OSTCrypto {
    
    func genSCryptKey(salt: Data, stringToCalculate: String) throws -> Data {
        var params = ScryptParams()
        params.n = 2
        params.r = 2
        params.p = 2
        params.desiredKeyLength = 32
        params.salt = salt
        
        let scrypt = Scrypt(params: params)
        do {
            let actual = try scrypt.calculate(password: stringToCalculate)
            return actual;
        }catch let error {
            throw error
        }
       
    }
    
     func genHKDFKey(salt saltBytes: [UInt8], data dataBytes: [UInt8]) throws -> [UInt8] {
        do {
            let hkdfOutput = try HKDF(password: dataBytes, salt: saltBytes, variant: .sha256).calculate()
            return hkdfOutput
        }catch let error{
            throw error
        }
    }
    
    func genDigest(bytes: [UInt8]) -> [UInt8] {
        let sha3Obj = SHA3.init(variant: .keccak256)
        let keccakOutput = sha3Obj.calculate(for: bytes)
       
        return keccakOutput
    }
    
    func aesGCMEncrypt(aesKey: [UInt8], dataToEncrypt: String) throws -> [UInt8] {
        do {
            let gcm = GCM(iv: Array("iv".utf8), mode: .combined)
            let aes = try AES(key: aesKey, blockMode: gcm, padding: .noPadding)
            
            let encrypted = try aes.encrypt(Array("Aniket".utf8))
            
            return encrypted
        }catch let error{
            throw error
        }
    }
    
    func aesGCMDecryption(aesKey: [UInt8], dataToDecrypt : [UInt8]) throws -> [UInt8] {
        do {
            let gcm = GCM(iv: Array("iv".utf8), mode: .combined)
            let aes = try AES(key: aesKey, blockMode: gcm, padding: .noPadding)
            
            let decrypted =  try aes.decrypt(dataToDecrypt)
            return decrypted
        }catch let error{
            throw error
        }
    }
}
