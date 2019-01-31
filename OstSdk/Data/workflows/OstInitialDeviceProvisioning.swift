//
//  OstInitialDeviceProvisioning.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public  class OstInitialDeviceProvisioning: OstWorkflowBase {
    
    override public func perform() throws -> Data? {
        do {
            let walletKeys: OstWalletKeys = try generateWalletKeys()
            guard let privateKeyData: Data = walletKeys.privateKey?.data(using: .utf8) else {
                throw OstError1(message: "key formation failed", type: .actionFailed)
            }
            
            let aesKeyData: Data = try getAesKey()
            print("aesKeyData : " + aesKeyData.toHexString())
            let hkdfKeyData: Data = try getHkdfKey(aesKey: aesKeyData)
            print("hkdfKeyData : " + hkdfKeyData.toHexString())
            let aheadData: Data = getAHEAD(hkdfKey: hkdfKeyData)
            print("aheadData : " + aheadData.toHexString())
            let encData: Data = try encryptData(aesKey: aesKeyData, ahead: aheadData, dataToEncrypt: privateKeyData)
            print("encData : " + encData.toHexString())
            return nil
        }catch let error{
            throw error
        }
    }
}
