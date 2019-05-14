/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import CryptoSwift
import EthereumKit
import SCrypt

class OstCryptoImpls: OstCrypto {
    
    static let PASSPHRASE_SEED_COMPONENT_OSTSDK = "OstSdk"

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
    func genSCryptKey(salt: Data, n:Int, r:Int, p: Int, size: Int, stringToCalculate: String) throws -> Data {
        let passphrase = stringToCalculate.bytes
        let salt = Array(salt)
        let powerOfTwo = pow(2, n)
        let powerOfTwoDecimalVal = NSDecimalNumber(decimal: powerOfTwo)
        let nVal = UInt64(truncating: powerOfTwoDecimalVal);
        
        let rVal = UInt32(r)
        let pVal = UInt32(p)
        var buffer = [CUnsignedChar](repeating: 0, count: Int(size));
        
        crypto_scrypt(passphrase,
                      passphrase.count,
                      salt,
                      salt.count,
                      nVal,
                      rVal,
                      pVal,
                      &buffer,
                      buffer.count)
    
        return Data(bytes: buffer)
    }
    
    /// Generate OST wallet keys
    ///
    /// - Parameters:
    ///   - userId: userId for whom the ethereum key has to be generated.
    ///   - forKeyType: KeyType for which ethereum key has to be generated.
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateOstWalletKeys(userId:String,
                               forKeyType keyType:KeyType) throws  -> OstWalletKeys {
        
        let mnemonics : [String] = Mnemonic.create()
        return try generateEthereumKeys(userId: userId,
                                        withMnemonics: mnemonics,
                                        forKeyType: keyType);
    }
    
    /// Generate OST wallet keys with 12 words mnemonics
    ///
    /// - Parameters:
    ///   - userId: userId for whom the ethereum key has to be generated.
    ///   - mnemonics: 12 words menemonics
    ///   - forKeyType: KeyType for which ethereum key has to be generated.
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateEthereumKeys(userId:String,
                              withMnemonics mnemonics: [String],
                              forKeyType keyType:KeyType) throws -> OstWalletKeys {
        
        let seedPassword = OstConfig.shouldUseSeedPassword() ?
            buildSeedPassword(userId: userId, forKeyType: keyType) : "";
        
        let seed: Data
        do {
            seed = try Mnemonic.createSeed(mnemonic: mnemonics, withPassphrase: seedPassword)
        } catch {
            throw OstError("s_i_ci_gek_1", .seedCreationFailed)
        }
        let wallet: Wallet
        do {
            // Wallet needs mandatory parameter network. We always pass .mainnet
            wallet = try Wallet(seed: seed,
                                network: OstConstants.OST_WALLET_NETWORK,
                                debugPrints: OstConstants.PRINT_DEBUG)
            
        } catch {
            throw OstError("s_i_ci_gek_2", .walletGenerationFailed)
        }
        
        let privateKey = wallet.privateKey()
        let publicKey = wallet.publicKey()
        let address = wallet.address()

        return OstWalletKeys(privateKey: privateKey.toHexString(),
                             publicKey: publicKey.toHexString(),
                             address: address,
                             mnemonics: mnemonics)
    }
    
    /// Build deterministic seed password
    ///
    /// - Parameters:
    ///   - userId: userId for whom the ethereum key has to be generated.
    ///   - forKeyType: KeyType for which ethereum key has to be generated.
    /// - Returns: String
    private func buildSeedPassword(userId:String,
                                   forKeyType keyType:KeyType) -> String {
        
        let components = [OstCryptoImpls.PASSPHRASE_SEED_COMPONENT_OSTSDK,
                          keyType.rawValue,
                          userId]
        let strToHash = components.joined(separator: "-");
        return strToHash.sha3(.keccak256).addHexPrefix();
    }
    
    /// Generate recovery passphrase
    ///
    /// - Parameters:
    ///   - passphrasePrefix: Passphrase prefix for recovery passphrase
    ///   - userPin: Pin for recovery passphrase
    ///   - userId: User id for recovery recovery
    ///   - salt: Salt data
    ///   - n: The `N` parameter of Scrypt encryption algorithm
    ///   - r: The `R` parameter of Scrypt encryption algorithm
    ///   - p: The `P` parameter of Scrypt encryption algorithm
    ///   - size: Desired key length in bytes.
    /// - Returns: Recovery address
    /// - Throws: OSTError
    func generateRecoveryKey(passphrasePrefix: String,
                             userPin: String,
                             userId: String,
                             salt: String,
                             n:Int,
                             r:Int,
                             p: Int,
                             size: Int) throws -> String {
        
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > passphrasePrefix.count {
            throw OstError("s_i_ci_grk_1",
                                 msg: "Passphrase prefix must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > userId.count {
            throw OstError("s_i_ci_grk_2",
                                 msg: "User id must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > userPin.count {
            throw OstError("s_i_ci_grk_3",
                                 msg: "User pin must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        let stringToCalculate: String = getRecoveryPinString(passphrasePrefix: passphrasePrefix,
                                                             userPin: userPin,
                                                             userId: userId)
        
        let seed: Data
        do {
            seed = try genSCryptKey(salt: salt.data(using: .utf8)!,
                                    n: n,
                                    r: r,
                                    p: p,
                                    size: size,
                                    stringToCalculate: stringToCalculate)
        } catch {
            throw OstError("s_i_ci_grk_4", .scryptKeyGenerationFailed)
        }
        
        let privateKey = HDPrivateKey(seed: seed, network: OstConstants.OST_WALLET_NETWORK)

        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: privateKey.privateKey().raw.toHexString(),
                                     debugPrints: OstConstants.PRINT_DEBUG)
        return wallet.address()
    }
    
    func getRecoveryPinString(passphrasePrefix: String,
                              userPin: String,
                              userId: String) -> String {
        return "\(passphrasePrefix)\(userPin)\(userId)"
    }
    
    func getWallet(
        passphrasePrefix: String,
        userPin: String,
        userId: String,
        salt: String,
        n:Int,
        r:Int,
        p: Int,
        size: Int) throws -> Wallet {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > passphrasePrefix.count {
            throw OstError("s_i_ci_grk_1",
                                msg: "Passphrase prefix must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > userId.count {
            throw OstError("s_i_ci_grk_2",
                                msg: "User id must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > userPin.count {
            throw OstError("s_i_ci_grk_3",
                                msg: "User pin must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        let stringToCalculate: String = getRecoveryPinString(passphrasePrefix: passphrasePrefix,
                                                             userPin: userPin,
                                                             userId: userId)
        
        let seed: Data
        do {
            seed = try genSCryptKey(salt: salt.data(using: .utf8)!,
                                    n: n,
                                    r: r,
                                    p: p,
                                    size: size,
                                    stringToCalculate: stringToCalculate)
        } catch {
            throw OstError("s_i_ci_grk_4", .scryptKeyGenerationFailed)
        }
        
        let privateKey = HDPrivateKey(seed: seed, network: OstConstants.OST_WALLET_NETWORK)
        
        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: privateKey.privateKey().raw.toHexString(),
                                     debugPrints: OstConstants.PRINT_DEBUG)
        return wallet
    }
}
