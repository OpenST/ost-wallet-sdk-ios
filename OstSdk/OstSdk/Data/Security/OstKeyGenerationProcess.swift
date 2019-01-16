//
//  OstKeyGenerationProcess.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation


public class OstKeyGenerationProcess {
    public init() {}
    
    public func perform() throws -> OstWalletKeys {
        do {
            let walletKeys: OstWalletKeys = try OstCryptoImpls().generateCryptoKeys()
            
            let _ : OstSecureKey = try OstSecureKey.storeSecKeySync(walletKeys.privateKey!, forKey: walletKeys.address!)
           
            return walletKeys
        }catch let error{
            throw error
        }
    }
}
