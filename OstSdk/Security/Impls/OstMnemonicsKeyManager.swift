/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstMnemonicsKeyManager {

    private let mnemonics: [String]
    private let userId: String
    private(set) var ethereumAddress: String? = nil

    // MARK: - Initializers
    
    /// Class initializer
    ///
    /// - Parameters:
    ///   - mnemonics: 12 words mnemonics
    ///   - userId: User id whose keys will be managed.
    init (withMnemonics mnemonics:[String], andUserId userId: String) {
        self.mnemonics = mnemonics
        self.userId = userId
    }
 
    /// Get address
    var address :  String? {
        if self.ethereumAddress == nil {
            do {
                _ = try createWallet()
            } catch {
                return nil
            }
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
        var isValid = true
        do {
            guard let ostWalletKeys: OstWalletKeys = try createWallet() else {
                return false
            }
            if (ostWalletKeys.privateKey == nil || ostWalletKeys.address == nil) {
                isValid = false
            }
        } catch {
            isValid = false
        }
        return isValid
    }
    
    /// Sign with Mnemonics
    ///
    /// - Parameter tx: Transaction string
    /// - Returns: Signed message
    /// - Throws: OstError
    func sign(_ tx: String) throws -> String {
        let keyManager = OstKeyManager(userId: self.userId)
        return try keyManager.sign(tx, withMnemonics: self.mnemonics)
    }
    
    /// Create OstWalletKey object
    ///
    /// - Returns: OstWalletKeys
    /// - Throws: OstError
    private func createWallet() throws -> OstWalletKeys? {
        do {
            let ostWalletKeys: OstWalletKeys = try OstCryptoImpls().generateEthereumKeys(withMnemonics: mnemonics)
            self.ethereumAddress = ostWalletKeys.address
            return ostWalletKeys
        } catch {
            return nil
        }
    }
}
