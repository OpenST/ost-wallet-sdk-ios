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
public class OstError1: Error {
    
    public let internalCode:String;
    public let errorMessage:String;
    public let messageTextCode:OstErrorText;
    public var message: String {
        return errorMessage
    }
    init(_ code: String, _ messageTextCode: OstErrorText) {
        self.internalCode = code
        self.errorMessage = messageTextCode.rawValue
        self.messageTextCode = messageTextCode;
    }
    
    @available(*, deprecated, message: "Please use OstError1(code:String, messageTextCode:OstErrorText)")
    init(_ code: String, _ errorMessage: String) {
        self.internalCode = code
        self.errorMessage = errorMessage
        self.messageTextCode = .tempMessageTextCode
    }
}

public enum OstErrorText: String {
    case userNotFound = "user not found."
    case invalidUser = "user is invalid."
    case userAlreadyActivated = "user is activated."
    case userNotActivated = "user is not activated."
    
    case deviceNotset = "device is not setup."
    case deviceNotAuthorized = "device is not authorized."
    case wrongDeviceAddress = "wrong device address."
    case deviceNotRegistered = "device is not registered."
    case registerSameDevice = "Trying to register same device."
    
    case accessControlFailed = "Unable to create access control object."
    case unableToGetPublicKey = "Unable to get public key."
    case encryptFail = "Error while encrypting data with public key."
    case decryptFail = "Error while decrypting data with private key."
    case keychainDeleteItemFail = "Error while deleting item from keychain."
    case keychainAddItemFail = "Error while adding item in keychain."
    case generatePrivateKeyFail = "Error while generating private key."
    case noPrivateKeyFound = "Private key not found."
    case mnemonicsNotStored = "Failed to store mnemonics."
    case scryptKeyGenerationFailed = "Failed to generate SCrypt key."
    case seedCreationFailed = "Failed to create seed from mnemonics."
    case walletGenerationFailed = "Failed to create wallet from seed."
    case signTxFailed = "Failed to sign transaction with private key."
    
    case invalidQRCode = "Invalid QR Code"
    
    //API-Errors
    case sessionApiFailed = "Failed to fetch session information."
    
    //To-Do: Temp code. Remove this.
    case tempMessageTextCode = ""
    case sdkError = "An internal SDK error has occoured."
}
