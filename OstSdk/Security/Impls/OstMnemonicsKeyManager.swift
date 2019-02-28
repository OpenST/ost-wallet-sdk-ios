//
//  OstMnemonicsKeyManager.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 28/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMnemonicsKeyManager: OstKeyManager{

    private let mnemonics: [String]
    private(set) var ethereumAddress: String? = nil

    // MARK: - Initializers
    
    /// Class initializer
    ///
    /// - Parameters:
    ///   - mnemonics: 12 words mnemonics
    ///   - userId: User id whose keys will be managed.
    init (withMnemonics mnemonics:[String], andUserId userId: String) {
        self.mnemonics = mnemonics
        super.init(userId: userId)                
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
        return try self.sign(tx, withMnemonics: self.mnemonics)
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
