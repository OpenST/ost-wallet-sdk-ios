//
//  OstBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 09/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public struct OstKeyGenerationParams {
    var aesSalt: String = ""
    var hkdfSalt: String = ""
    var iv: String = ""
    var uPin: String = ""
    
    var aesSaltData: Data {
        return aesSalt.data(using: .utf8)!
    }
    
    var hkdfSaltData: Data {
        return hkdfSalt.data(using: .utf8)!
    }
    
    var ivData: Data {
        return iv.data(using: .utf8)!
    }
    
    var uPinData: Data {
        return uPin.data(using: .utf8)!
    }
    
    public  init(aesSalt: String = "aesSalt", hkdfSalt: String = "hkdfSalt", iv: String = "iv", uPin: String = "uPin") {
        self.aesSalt = aesSalt
        self.hkdfSalt = hkdfSalt
        self.iv = iv
        self.uPin = uPin
    }
    
}

public class OstWorkflowBase {
    var keyGenerationParams: OstKeyGenerationParams
    
    public init(_ keyGenerationParams: OstKeyGenerationParams) {
        self.keyGenerationParams = keyGenerationParams
    }
    
    public func perform() throws -> Data? {
        fatalError("************* perform didnot override ******************")
    }
   
    //MARK: - internal methods
    func generateWalletKeys() throws -> OstWalletKeys {
        return try OstKeyGenerationProcess().perform()
    }
    
    func getAesKey() throws -> Data {
        return try OstCryptoImpls().genSCryptKey(salt: keyGenerationParams.aesSaltData,
                                                 stringToCalculate: keyGenerationParams.uPin)
    }
    
    func getHkdfKey(aesKey: Data) throws -> Data {
        do {
            let hkdfKey: [UInt8] = try OstCryptoImpls().genHKDFKey(salt: Array(keyGenerationParams.hkdfSaltData), data: Array(aesKey))
            return Data(bytes: hkdfKey)
        }catch let error {
            throw error
        }
    }
    
    func getAHEAD(hkdfKey: Data) -> Data {
        let aheadData = OstCryptoImpls().genDigest(bytes: Array(hkdfKey))
        return Data(bytes: aheadData)
    }
    
    func encryptData(aesKey: Data, ahead: Data, dataToEncrypt: Data) throws -> Data {
        do {
            let encData = try OstCryptoImpls().aesGCMEncrypt(aesKey: Array(aesKey),
                                                             iv: Array(keyGenerationParams.ivData),
                                                             ahead: Array(ahead),
                                                             dataToEncrypt: Array(dataToEncrypt))
            return Data(bytes: encData)
        }catch let error {
            throw error
        }
    }
    
    func decryptData(aesKey: Data, ahead: Data?, dataToDecrypt: Data) throws -> Data {
        do {
            let encData = try OstCryptoImpls().aesGCMDecrypt(aesKey: Array(aesKey),
                                                             iv: Array(keyGenerationParams.ivData),
                                                             ahead: ahead == nil ? nil : Array(ahead!),
                                                             dataToDecrypt: Array(dataToDecrypt))
            return Data(bytes: encData)
        }catch let error {
            throw error
        }
    }
    
}
