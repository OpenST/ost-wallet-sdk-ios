/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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

enum KeyType: String {
    case api = "API"
    case device = "DEVICE"
    case session = "SESSION"
    case recovery = "RECOVERY"
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
    func genSCryptKey(salt: Data,
                      n:Int,
                      r:Int,
                      p: Int,
                      size: Int,
                      stringToCalculate: String) throws -> Data
    
    /// Generate OST wallet keys
    ///
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateOstWalletKeys(userId:String,
                               forKeyType:KeyType) throws -> OstWalletKeys
}
