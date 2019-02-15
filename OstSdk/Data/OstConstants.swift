//
//  OstConstants.swift
//  OstSdk
//
//  Created by aniket ayachit on 24/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit

struct OstConstants {
    
    static let TOKEN_CHAIN_ID: String = "123"
    
    static let TOKEN_ID: String = "58"
    
    static let OST_ALGORITHM_CRYPTO_SUITE: String = "1.0"
    static let OST_KEYCHAIN_VERSION: String = "1.0"
    static let PIN_WALLET_ALGORITH_ID: String = ""
    static let PAPER_WALLET_ALOGRITH_ID: String = ""
    
    static let OST_SCRYPT_N: Int = 2
    static let OST_SCRYPT_P: Int = 2
    static let OST_SCRYPT_R: Int = 2
    static let OST_SCRYPT_DESIRED_SIZE_BYTES: Int = 32
    
    static let OST_API_BASE_URL = "https://s4-api.stagingost.com/testnet/v2"
    static let OST_SIGNATURE_KIND = "OST1-PS"
    static let OST_USER_AGENT = "ost-sdk-js " + OstConstants.OST_API_VERSION
    static let OST_API_VERSION = "1.1.0"
    
    
    static let OST_RECOVERY_KEY_PIN_MIN_LENGTH = 6;
    static let OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH = 30;
    static let OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH = 4;
    
    static let OST_WALLET_NETWORK: Network = .mainnet
    static let OST_WALLET_SEED_PASSPHRASE: String = ""
    
    static let OST_BLOCK_FORMATION_TIME: Int = 3
}
