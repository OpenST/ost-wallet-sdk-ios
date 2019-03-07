//
//  OstCryptoImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift
import EthereumKit
import SCrypt

class OstCryptoImpls: OstCrypto {

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
        let password = "stringToCalculate".bytes
        let salt = Array(salt)
        let powerOfTwo = pow(2, n)
        let powerOfTwoDecimalVal = NSDecimalNumber(decimal: powerOfTwo)
        let nVal = UInt64(truncating: powerOfTwoDecimalVal);
        
        let rVal = UInt32(r)
        let pVal = UInt32(p)
        var buffer = [CUnsignedChar](repeating: 0, count: Int(size));
        
        crypto_scrypt(password,
                      password.count,
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
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateOstWalletKeys() throws  -> OstWalletKeys {
        let mnemonics : [String] = Mnemonic.create()
        return try generateEthereumKeys(withMnemonics: mnemonics)
    }
    
    /// Generate OST wallet keys with 12 words mnemonics
    ///
    /// - Parameter mnemonics: 12 words menemonics
    /// - Returns: OstWalletKeys object
    /// - Throws: OSTError
    func generateEthereumKeys(withMnemonics mnemonics: [String]) throws -> OstWalletKeys {
        let seed: Data
        do {
            // TODO: Discuss this with wider audience to decide if passphrase really needs to be in Constants. Looks incorrect to me.
            // The passphrase must always be equal to empty string. This is in consistent with the Metamask.
            seed = try Mnemonic.createSeed(mnemonic: mnemonics, withPassphrase: OstConstants.OST_WALLET_SEED_PASSPHRASE)
        } catch {
            throw OstError.init("s_i_ci_gek_1", .seedCreationFailed)
        }
        let wallet: Wallet
        do {
            // Wallet needs mandatory parameter network. We always pass .mainnet
            wallet = try Wallet(seed: seed, network: OstConstants.OST_WALLET_NETWORK, debugPrints: OstConstants.PRINT_DEBUG)
        } catch {
            throw OstError.init("s_i_ci_gek_2", .walletGenerationFailed)
        }
        
        let privateKey = wallet.privateKey()
        let publicKey = wallet.publicKey()
        let address = wallet.address()

        return OstWalletKeys(privateKey: privateKey.toHexString(),
                             publicKey: publicKey.toHexString(),
                             address: address,
                             mnemonics: mnemonics)
    }        
    
    /// Generate recovery password
    ///
    /// - Parameters:
    ///   - password: Password for recovery password generation
    ///   - pin: Pin for recovery password generation
    ///   - userId: User id for which the recovery password is needed
    ///   - salt: Salt data
    ///   - n: The `N` parameter of Scrypt encryption algorithm
    ///   - r: The `R` parameter of Scrypt encryption algorithm
    ///   - p: The `P` parameter of Scrypt encryption algorithm
    ///   - size: Desired key length in bytes.
    /// - Returns: Recovery address
    /// - Throws: OSTError
    func generateRecoveryKey(password: String,
                             pin: String,
                             userId: String,
                             salt: String,
                             n:Int,
                             r:Int,
                             p: Int,
                             size: Int) throws -> String {
        
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > password.count {
            throw OstError.init("s_i_ci_grk_1",
                                 "Password must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > userId.count {
            throw OstError.init("s_i_ci_grk_2",
                                 "User id must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > pin.count {
            throw OstError.init("s_i_ci_grk_3",
                                 "Pin must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        let stringToCalculate: String = getRecoveryPinString(password: password, pin: pin, userId: userId)
//        try OstKeyManager(userId: userId).storeRecoveryPinString(stringToCalculate)
        
        let seed: Data
        do {
            seed = try genSCryptKey(salt: salt.data(using: .utf8)!,
                                    n: n,
                                    r: r,
                                    p: p,
                                    size: size,
                                    stringToCalculate: stringToCalculate)
        } catch {
            throw OstError.init("s_i_ci_grk_4", .scryptKeyGenerationFailed)
        }
        
        let privateKey = HDPrivateKey(seed: seed, network: OstConstants.OST_WALLET_NETWORK)

        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: privateKey.privateKey().raw.toHexString(),
                                     debugPrints: OstConstants.PRINT_DEBUG)
        return wallet.address()
    }
    
    func getRecoveryPinString(password: String, pin: String, userId: String) -> String {
        return "\(password)\(pin)\(userId)"
    }
    //TODO: Remove this code asap.
    func getWallet(
        password: String,
        pin: String,
        userId: String,
        salt: String,
        n:Int,
        r:Int,
        p: Int,
        size: Int) throws -> Wallet {
        if OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH > password.count {
            throw OstError.init("s_i_ci_grk_1",
                                "Password must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH > userId.count {
            throw OstError.init("s_i_ci_grk_2",
                                "User id must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH)")
        }
        
        if OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH > pin.count {
            throw OstError.init("s_i_ci_grk_3",
                                "Pin must be minimum of length \(OstConstants.OST_RECOVERY_KEY_PIN_MIN_LENGTH)")
        }
        
        let stringToCalculate: String = getRecoveryPinString(password: password, pin: pin, userId: userId)
        
        let seed: Data
        do {
            seed = try genSCryptKey(salt: salt.data(using: .utf8)!,
                                    n: n,
                                    r: r,
                                    p: p,
                                    size: size,
                                    stringToCalculate: stringToCalculate)
        } catch {
            throw OstError.init("s_i_ci_grk_4", .scryptKeyGenerationFailed)
        }
        
        let privateKey = HDPrivateKey(seed: seed, network: OstConstants.OST_WALLET_NETWORK)
        
        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: privateKey.privateKey().raw.toHexString(),
                                     debugPrints: OstConstants.PRINT_DEBUG)
        return wallet
    }
}
