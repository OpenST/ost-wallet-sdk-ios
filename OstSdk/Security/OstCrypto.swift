//
//  OstSecure.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

/// Structure to store wallet keys.
struct OstWalletKeys {
    /// Private key that is used for signing
    var privateKey: String?
    
    /// Public key
    var publicKey: String?
    
    /// Ethererum address
    var address: String?
    
    /// 12 works mnemonics that can be used to recreate the wallet.
    var mnemonics: [String]?
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - privateKey: Private key that is used for signing
    ///   - publicKey: Public key
    ///   - address: Ethererum address
    ///   - mnemonics: 12 works mnemonics that can be used to recreate the wallet.
    init(privateKey: String? = nil, publicKey: String? = nil, address: String? = nil, mnemonics: [String]? = nil) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.address = address
        self.mnemonics = mnemonics
    }
}

protocol OstCrypto {
    
    /// Get the data that will be used for private key generation
    ///
    /// - Parameters:
    ///   - salt: Salt data
    ///   - n: The `N` parameter of Scrypt encryption algorithm
    ///   - r: The `R` parameter of Scrypt encryption algorithm
    ///   - p: The `P` parameter of Scrypt encryption algorithm
    ///   - size: Desired key length in bytes.
    ///   - stringToCalculate: String to calculate the data
    /// - Returns: Data that can be used for OSTWalletKeys generation
    /// - Throws: OSTError
    func genSCryptKey(salt: Data, n:Int, r:Int, p: Int, size: Int, stringToCalculate: String) throws -> Data
    
    /// Generate OST wallet keys
    ///
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateOstWalletKeys() throws -> OstWalletKeys
}
