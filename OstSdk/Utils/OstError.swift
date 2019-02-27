//
//  OstError.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstError: Error {
    
    public let internalCode:String
    public let errorMessage:String
    public var description: String {
        return errorMessage
    }
    public var errorInfo: [String: Any]? = nil

    init(_ code: String, _ messageTextCode: OstErrorText) {
        self.internalCode = code
        errorMessage = messageTextCode.rawValue
    }
    init(_ code: String, _ errorMessage: String) {
        self.internalCode = code
        self.errorMessage = errorMessage
    }
    init(fromApiResponse response: [String: Any]) {
        let err = response["err"] as! [String: Any]
        self.internalCode = err["code"] as! String
        self.errorMessage = err["msg"] as! String
        errorInfo = response
    }
}

public enum OstErrorText: String {
    case userNotFound = "user not found."
    case invalidUser = "user is invalid."
    case deviceNotset = "Device is not setup. Please Setup device first. call OstSdk.setupDevice"
    case userAlreadyActivated = "user is activated."
    case accessControlFailed = "Unable to create access control object."
    case unableToGetPublicKey = "Unable to get public key."
    case encryptFail = "Error while encrypting data with public key."
    case decryptFail = "Error while decrypting data with private key."
    case keychainDeleteItemFail = "Error while deleting item from keychain."
    case keychainAddItemFail = "Error while adding item in keychain."
    case generatePrivateKeyFail = "Error while generating private key."
    case noPrivateKeyFound = "Private key not found."
    case mnemonicsNotStored = "Failed to store mnemonics."
    case mnemonicsNotFound = "Mnemonics not found."
    case scryptKeyGenerationFailed = "Failed to generate SCrypt key."
    case seedCreationFailed = "Failed to create seed from mnemonics."
    case walletGenerationFailed = "Failed to create wallet from seed."
    case signTxFailed = "Failed to sign transaction with private key."
    case apiEndpointNotFound = "API endpoint not found."
    case userEntityNotFound = "User not found."
    case entityNotAvailable = "Entity not available."
    case unknownEntity = "Unknown entity."
    case invalidAPIResponse = "Invalid API response."
    case unableToGetSalt = "Unable to get salt."
    case unableToChainInformation = "Unable to get chain information."
    case deviceNotRegistered = "Device is not registered."
    case deviceManagerNotFound = "Device manager is not persent."
    case userActivationFailed = "Activation of user failed."
    case deviceNotFound = "Device not found."
    case invalidPayload = "Invalid paylaod to process."
    case paperWalletNotFound = "Paper wallet not found."
    case invalidDataDefination = "Invalid data defination"
    case recoveryAddressNotFound = "Recovery address for user is not set."
    case invalidUserId = "Invalid user id."
    case invalidTokenId = "Invalid token id."
    case signatureGenerationFailed = "Signature generation failed."
    case unexpectedError = "Unexpected error."
    case abiEncodeFailed = "ABI encoding failed."
    case qrReadFailed = "Can not read data from given image."
    case qrCodeGenerationFailed = "QR-Code generation failed."
    case qrCodeImageGenerationFailed = "QR-Code image generation failed."
    case functionNotFoundInABI = "Generating ABI encodable values failed."
    case failedWithMaxRetryCount = "Failed after maximum retry count."
    case invalidSolidityTypeInt = "Invalid solidity type, expected Int or Uint."
    case invalidSolidityTypeAddress = "Invalid solidity type address."
    case invalidJsonObjectIdentifier = "JsonObject doesn't have desired identifier"
    case jsonConversionFailed = "JSON conversion to object failed."
    case addDeviceFlowCancelled = "Add device flow cancelled."
    case objectCreationFailed = "Object creation failed."
    case invalidId = "Invalid id."
    case unexpectedState = "Unexpected state."
    case toAddressNotFound = "To address not found."
    case signerAddressNotFound = "Signer address not found."
    case dbExecutionFailed = "DB execution failed."
    case invalidEntityType = "Invalid entity type."
}
