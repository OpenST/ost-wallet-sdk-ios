//
//  OstError.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstError: Error {
    case invalidInput(String?), actionFailed(String?), unauthorized(String?)
    
    public var description: String? {
        switch self {
        case .invalidInput(let str):
            return str
        case .actionFailed(let str):
            return str
        case .unauthorized(let str):
            return str
        }
    }
}

public enum OstEntityError: Error {
    case validationFailed(String?)
}

public enum OstErrorType {
    case invalidInput, actionFailed
}

// TODO: Remove OSTError and rename OSTError1 to OSTError.
internal class OstError1: Error {
    
    public let internalCode:String
    public var message: String {
        return errorCode.rawValue
    }
    public let errorCode: OstErrorText
    
    init(_ code: String, _ messageTextCode: OstErrorText) {
        self.internalCode = code
        self.errorCode = messageTextCode
    }
}

public enum OstErrorText: String {
    case invalidUser = "user is invalid."
    case deviceNotset = "device is not setup."
    case accessControlFailed = "Unable to create access control object."
    case unableToGetPublicKey = "Unable to get public key."
    case encryptFail = "Error while encrypting data with public key."
    case decryptFail = "Error while decrypting data with private key."
    case keychainDeleteItemFail = "Error while deleting item from keychain."
    case keychainAddItemFail = "Error while adding item in keychain."
    case generatePrivateKeyFail = "Error while generating private key."
    case noPrivateKeyFound = "Private key not found."
    case mnemonicsNotStored = "Failed to store mnemonics."
    
}
