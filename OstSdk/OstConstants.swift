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
    
    static let OST_RECOVERY_PIN_SCRYPT_N: Int = 14 // power of 2
    static let OST_RECOVERY_PIN_SCRYPT_P: Int = 1
    static let OST_RECOVERY_PIN_SCRYPT_R: Int = 8
    static let OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES: Int = 32
    
    static let OST_CONTENT_TYPE = "application/x-www-form-urlencoded"
    static let OST_SIGNATURE_KIND = "OST1-PS"
    static let OST_API_VERSION = "2"
    static let OST_USER_AGENT = "ost-sdk-ios-\(OstConstants.OST_API_VERSION)-\(OstSdkVersionNumber)"
    
    
    static let OST_RECOVERY_KEY_PIN_MIN_LENGTH = 6;
    static let OST_RECOVERY_KEY_PIN_PREFIX_MIN_LENGTH = 30;
    static let OST_RECOVERY_KEY_PIN_POSTFIX_MIN_LENGTH = 4;
    
    static let OST_WALLET_NETWORK: Network = .mainnet
    static let OST_WALLET_SEED_PASSPHRASE: String = ""
    
    static let PRINT_DEBUG = false
    
    // Following constants must come from config
    static let OST_BLOCK_GENERATION_TIME: Int = 3
    static let OST_PRICE_POINT_TOKEN_SYMBOL = "OST"
    static let OST_PRICE_POINT_CURRENCY_SYMBOL = "USD"
    
    // Request time out duration in seconds
    static let OST_REQUEST_TIMEOUT_DURATION: Int = 6
    static let OST_PIN_MAX_RETRY_COUNT: Int = 3
    
    static let OST_SESSION_BUFFER_TIME = Double(1 * 60 * 60) //1 Hour.
    
}
