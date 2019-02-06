//
//  OstConstants.swift
//  OstSdk
//
//  Created by aniket ayachit on 24/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

struct OstConstants {
    
    static let OST_SDK_VERIOS: String = "1.0"
    static let OST_KEYCHAIN_VERSION: String = "1.0"
    
    static let OST_SCRYPT_N: Int = 2
    static let OST_SCRYPT_P: Int = 2
    static let OST_SCRYPT_R: Int = 2
    static let OST_SCRYPT_DESIRED_SIZE_BYTES: Int = 32
    
    static let OST_API_BASE_URL = "https://s4-api.stagingost.com/testnet/v2"
    static let OST_SIGNATURE_KIND = "OST1-PS"
    static let OST_USER_AGENT = "ost-sdk-js " + OstConstants.OST_API_VERSION
    static let OST_API_VERSION = "1.1.0"
}
