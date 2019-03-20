/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import EthereumKit

struct OstConstants {
    
    static let OST_RECOVERY_PIN_SCRYPT_N: Int = 14 // power of 2
    static let OST_RECOVERY_PIN_SCRYPT_P: Int = 1
    static let OST_RECOVERY_PIN_SCRYPT_R: Int = 8
    static let OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES: Int = 32
    
    static let OST_CONTENT_TYPE = "application/x-www-form-urlencoded"
    static let OST_SIGNATURE_KIND = "OST1-PS"
    static let OST_API_VERSION = "2"
    static let OST_USER_AGENT = "ost-sdk-ios-\(OstConstants.OST_API_VERSION)-\(OstWalletSdkVersionNumber)"
    
    
    static let OST_RECOVERY_KEY_PIN_MIN_LENGTH = 6;
    static let OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH = 30;
    static let OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH = 4;
    
    static let OST_WALLET_NETWORK: Network = .mainnet
    static let OST_WALLET_SEED_PASSPHRASE: String = ""
    
    static let PRINT_DEBUG = false                
    
}
