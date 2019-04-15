/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstMnemonicsKeyManager {

    let mnemonics: [String]
    private let userId: String
    private(set) var ethereumAddress: String? = nil
    
    /// Class initializer
    ///
    /// - Parameters:
    ///   - mnemonics: 12 words mnemonics
    ///   - userId: User id whose keys will be managed.
    init (withMnemonics mnemonics:[String],
          andUserId userId: String) {
        
        self.mnemonics = mnemonics
        self.userId = userId
    }
 
    /// Get address
    var address :  String? {
        if self.ethereumAddress == nil {
            _ = createWallet()
        }
        return ethereumAddress
    }
    
    /// Check if the Mnemonics is valid
    ///
    /// - Returns: `true` if valid otherwise `false`
    func isMnemonicsValid() -> Bool {
        let filteredWordsArray = self.mnemonics.filter({ $0 != ""})
        if (filteredWordsArray.isEmpty) {
            return false
        }
        return isValidMnemonics()
    }
    
    /// Validate mnemonics
    ///
    /// - Returns: Boolean
    private func isValidMnemonics() -> Bool {
        guard let ostWalletKeys: OstWalletKeys = createWallet() else {
            return false
        }
        if (ostWalletKeys.privateKey == nil
            || ostWalletKeys.address == nil) {
            
            return false
        }
        return true
    }
    
    /// Create OstWalletKey object
    ///
    /// - Returns: OstWalletKeys
    /// - Throws: OstError
    private func createWallet() -> OstWalletKeys? {
        do {
            let ostWalletKeys: OstWalletKeys = try OstCryptoImpls()
                .generateEthereumKeys(userId: self.userId,
                                      withMnemonics: mnemonics,
                                      forKeyType: .device)
            
            self.ethereumAddress = ostWalletKeys.address
            return ostWalletKeys
        } catch {
            return nil
        }
    }
}
