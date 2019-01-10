//
//  OSTInitialDeviceProvisioning.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public  class OSTInitialDeviceProvisioning: OSTWorkflowBase {
    
    override public func perform() throws -> Data {
        do {
            let walletKeys: OSTWalletKeys = try generateWalletKeys()
            guard let privateKeyData: Data = walletKeys.privateKey?.data(using: .utf8) else {
                throw OSTError.actionFailed("key formation failed")
            }
            
            let aesKeyData: Data = try getAesKey()
            print("aesKeyData : " + aesKeyData.toHexString())
            let hkdfKeyData: Data = try getHkdfKey(aesKey: aesKeyData)
            print("hkdfKeyData : " + hkdfKeyData.toHexString())
            let aheadData: Data = getAHEAD(hkdfKey: hkdfKeyData)
            print("aheadData : " + aheadData.toHexString())
            let encData: Data = try encryptData(aesKey: aesKeyData, ahead: aheadData, dataToEncrypt: privateKeyData)
            print("encData : " + encData.toHexString())
            return encData
        }catch let error{
            throw error
        }
    }
}


//var params: [String: Any]
//public init(params: [String: Any]) throws {
//    if params["mPayload"] == nil || params["mSignature"] == nil {
//        throw OSTError.invalidInput("mPayload and mSignature are mandetory")
//    }
//    self.params = params
//}
//
//override func perform() {
//    let walKey = self.
//}
//
//public func crateWalletKeys() throws {
//    do {
//        let wallteKeys: OSTWalletKeys = try OSTCryptoImpls().generateCryptoKeys()
//        let sign1: String = try OSTCryptoImpls().signTx("c11e96ba445075d92706097a17994b0cc0d991515a40323bf4c0b55cb0eff751", withPrivatekey: wallteKeys.privateKey!)
//        print("sig1 : \(sign1)")
//        let encData = try OSTSecureStoreImpls(address: wallteKeys.address!).encrypt(data: wallteKeys.privateKey!.data(using: .utf8)!)
//
//        OSTSecureKeyRepository.sharedSecureKey.save(["key":wallteKeys.address!,"data":encData!], success: { (sec) in
//            do {
//                let secData1: OSTSecureKey? = try OSTSecureKeyRepository.sharedSecureKey.get(wallteKeys.address!)
//
//                let decData = try OSTSecureStoreImpls(address: wallteKeys.address!).decrypt(data: secData1!.secData)
//                let privateKey = String(data: decData!, encoding: .utf8)!
//                print("privateKey : \(privateKey)")
//                let sign2: String = try OSTCryptoImpls().signTx("0xc11e96ba445075d92706097a17994b0cc0d991515a40323bf4c0b55cb0eff751", withPrivatekey: privateKey)
//                print("sig2 : \(sign2)")
//                OSTSecureKeyRepository.sharedSecureKey.delete(wallteKeys.address!, success: nil)
//            }catch let error{
//                print(error)
//            }
//
//        }, failure: { (error) in
//            print(error)
//        })
//
//    }catch let error {
//        print(error)
//    }
//}
