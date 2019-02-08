//
//  OstCryptoImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift
import EthereumKit

class OstCryptoImpls: OstCrypto {
    
    func genSCryptKey(salt: Data, n:Int, r:Int, p: Int, size: Int, stringToCalculate: String) throws -> Data {
        var params = ScryptParams()
        params.n = n
        params.r = r
        params.p = p
        params.desiredKeyLength = size
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
    
    func aesGCMEncrypt(aesKey: [UInt8], iv: [UInt8], ahead: [UInt8], dataToEncrypt: [UInt8]) throws -> [UInt8] {
        do {
            let gcm = GCM(iv: iv, authenticationTag: ahead, mode: .combined)
            let aes = try AES(key: aesKey, blockMode: gcm, padding: .noPadding)
            let encrypted = try aes.encrypt(dataToEncrypt)
            return encrypted
        }catch let error{
            throw error
        }
    }
    
    func aesGCMDecrypt(aesKey: [UInt8], iv: [UInt8], ahead: [UInt8]?, dataToDecrypt : [UInt8]) throws -> [UInt8] {
        do {
            let gcm = GCM(iv: iv, mode: .combined)
            gcm.authenticationTag = ahead
        
            let aes = try AES(key: aesKey, blockMode: gcm, padding: .noPadding)
            let decrypted =  try aes.decrypt(dataToDecrypt)
            return decrypted
        }catch let error{
            throw error
        }
    }
    
    func generateCryptoKeys() throws  -> OstWalletKeys {
        let mnemonics : [String] = Mnemonic.create()
        Logger.log(message: "mnemonics", parameterToPrint: mnemonics)
        
        let seed = try! Mnemonic.createSeed(mnemonic: mnemonics, withPassphrase: OstConstants.OST_WALLET_SEED_PASSPHRASE)
        let wallet: Wallet
        do {
            wallet = try Wallet(seed: seed, network: OstConstants.OST_WALLET_NETWORK, debugPrints: true)
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    
        let privateKey = wallet.privateKey()
        let publicKey = wallet.publicKey()
        let address = wallet.address()
        return OstWalletKeys(privateKey: privateKey.toHexString(), publicKey: publicKey.toHexString(), address: address, mnemonics: mnemonics)
    }
    
    func signTx(_ tx: String, withPrivatekey privateKey: String) throws -> String {
        let priKey : PrivateKey = PrivateKey(raw: Data(hex: privateKey))
        
        var singedData = try priKey.sign(hash: Data(hex: tx))
        singedData[64] += 27
        let singedTx = singedData.toHexString().addHexPrefix();
        return singedTx
    }
    
    func generateRecoveryKey(pinPrefix: String, pin: String, pinPostFix: String, salt: String, n:Int, r:Int, p: Int, size: Int) throws -> String {
        
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH >= pinPrefix.count {
            throw OstError.invalidInput("pinPrefix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH >= pinPostFix.count {
            throw OstError.invalidInput("pinPostfix should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH >= pin.count {
            throw OstError.invalidInput("pin should be of lenght \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        let stringToCalculate: String = pinPrefix+pin+pinPostFix
        let seed: Data = try! genSCryptKey(salt: salt.data(using: .utf8)!, n: n, r: r, p: p, size: size, stringToCalculate: stringToCalculate)
        
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK, privateKey: privateKey.privateKey().raw.toHexString(), debugPrints: true)
        Logger.log(message: "address", parameterToPrint: wallet.address())
        
        return wallet.address()
    }
}
