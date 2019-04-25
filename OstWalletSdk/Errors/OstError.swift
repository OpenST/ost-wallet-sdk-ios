/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstError: Error {
    
    public internal(set) var isApiError = false
    private var _internalCode: String = ""
    public var internalCode:String {
        set(code) {
//            _internalCode = "v\(OstBundle.getSdkVersion())_\(code)"
            _internalCode = code
        }get {
            return _internalCode
        }
    }
    public let errorMessage:String
    public let messageTextCode:OstErrorText;
    
    public var description: String {
        return errorMessage
    }
    public var errorInfo: [String: Any]? = nil

    init(_ code: String, _ messageTextCode: OstErrorText) {
        self.errorMessage = messageTextCode.rawValue
        self.messageTextCode = messageTextCode
        self.internalCode = code
    }
    
    //@available(*, deprecated, message: "Please use OstError(code:String, messageTextCode:OstErrorText)")
    init(_ code: String, msg errorMessage: String) {
        self.errorMessage = errorMessage
        self.messageTextCode = .tempMessageTextCode
        self.internalCode = code
    }
    
    init(fromApiResponse response: [String: Any]) {
        let err = response["err"] as! [String: Any]
        self.errorMessage = err["msg"] as! String
        self.messageTextCode = OstErrorText.apiResponseError;
        errorInfo = response
        self.internalCode = err["code"] as! String
    }
}

public enum OstErrorText: String {
    case userNotFound = "Unable to find this user in your economy. Inspect if a correct value is being sent in user Id field and its not null. Re-submit after verification."
    case invalidUser = "Unable to recognize the user. Please ensure user id is not null and re-submit the request."
    case userAlreadyActivated = "This User is already activated"
    case userNotActivated = "This user is not activated yet. Please setup user's wallet to enable their participation in your economy."
    case userNotActivating = "User is not activating"
    case deviceNotSet = "Unable to recognize the device. Please setup this device for the user using workflows provided at https://dev.ost.com/platform/docs/sdk"
    case deviceNotAuthorized = "Unable to perform the operation as the device is not authorized. For details on how to authorize a device please visit https://dev.ost.com/platform/docs/sdk"
    case deviceAuthorized = "This Device is already authorized."
    case deviceNotRecovering = "This Device is not in recovering mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com"
    case deviceNotRevoking = "This Device is not in revoking mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com"
    case deviceNotAuthorizing = "Device is not in authorizing mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com"
    case wrongDeviceAddress = "Incorrect device address. Please inspect the value being sent is correct and not null, rectify and re-submit."
    case processSameDevice = "Trying to process same device."
    case differentOwnerDevice = "The device is not registered with the user, so the operation could not be complete. Inspect if a correct value is being sent and re-submit."
    case accessControlFailed = "Unable to perform the operation on the given resource due to restricted access."
    case unableToGetPublicKey = "Unable to get public key. Please ensure the input is well formed or visit https://dev.ost.com/platform/docs/api for details on accepted datatypes for API parameters."
    case encryptFail = "Error while encrypting data with public key."
    case decryptFail = "Error while decrypting data with private key."
    case keychainDeleteItemFail = "Error while deleting item from keychain."
    case keychainAddItemFail = "Error while adding item in keychain."
    case generatePrivateKeyFail = "Error while generating private key."
    case noPrivateKeyFound = "Private key not found."
    case mnemonicsNotStored = "Unable to store the 12 words mnemonics. Please try again."
    case mnemonicsNotFound = "The 12 words mnemonics you provided is either incorrect or null."
    case scryptKeyGenerationFailed = "Failed to generate SCrypt key."
    case seedCreationFailed = "Failed to generate Recovery key. Inspect if a correct input values required are being sent and re-submit the request."
    case walletGenerationFailed = "Failed to create wallet. Inspect if a correct input values required are being sent. Please follow the recovery flow guide on https://dev.ost.com/platform/docs for details on input parameters."
    case signTxFailed = "Unable to sign transaction data with private key. Visit https://dev.ost.com/platform/docs/sdk for detailed SDK references. Please ensure the input is well formed and re-submit the request."
    case signatureFailed = "Unable to sign message with private key. Visit https://dev.ost.com/platform/docs/sdk for detailed SDK references. Please ensure the input is well formed and re-submit the request."
    case apiAddressNotFound = "API address not found."
    case apiEndpointNotFound = "API endpoint not found."
    case userEntityNotFound = "Unable to find this user in your economy. Inspect if a correct value is being sent in user Id field and re-submit the request."
    case entityNotAvailable = "Unable to recognize the API response entity sent and so cannot be executed."
    case invalidAPIResponse = "Unable to recognize the API response object sent and so cannot be executed."
    case unableToGetSalt = "Failed to fetch user salt. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later."
    case unableToChainInformation = "Failed to fetch block-chain information. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later."
    case deviceNotRegistered = "Please ensure the device is 'Registered' for this user with OST platform. Only a registered device can do wallet operations."    
    case deviceAlreadyRegistered = "Device is registered."
    case deviceManagerNotFound = "Device manager is not persent. This means either the user activation is in progress or has not started at all. Please ensure user activation workflow is complete successfully."
    case userActivationFailed = "Unable to complete the user activation flow. Inspect if correct input values are being sent, the input is well formed and re-try. If the problem persists contact support@ost.com"
    case invalidPayload = "Invalid paylaod to process."
    case paperWalletNotFound = "Paper wallet not found."
    case invalidDataDefination = "The QR code for doing this operation is not well formed. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform "
    case recoveryAddressNotFound = "Recovery address is not set for this user. This address is set during user activation. Please verify the user has been successfully activated."
    case recoveryOwnerAddressNotFound = "Recovery owner address is not set for this user. This address is set during user activation. Please verify the user has been successfully activated."
    case recoveryOwnerAddressCreationFailed = "Recovery owner address creation failed. This address is created during user activation. Please verify the user has been successfully activated."
    case linkedAddressNotFound = "Linked address for user is not set."
    case invalidRecoveryAddress = "Invalid recovery address. Please ensure the recovery address is not null."
    case invalidUserId = "Unable to recognize the user id. Please inspect for what is being sent, rectify and re-submit."
    case invalidTokenId = "Unable to recognize the token id. Please inspect for what is being sent, rectify and re-submit."
    case tokenNotFound = "Incorrect token for your economy. Inspect if a correct value is being sent in token Id field and re-submit the request."
    case signatureGenerationFailed = "Signature generation failed."
    case unexpectedError = "Unexpected error."
    case abiEncodeFailed = "ABI encoding failed."
    case qrReadFailed = "Unable to read QR code data from given image. The QR code might not contain valid data definition. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform"
    case qrCodeGenerationFailed = "QR-Code generation failed."
    case qrCodeImageGenerationFailed = "QR-Code image generation failed."
    case functionNotFoundInABI = "Generating ABI encodable values failed."
    case invalidSolidityTypeInt = "Invalid solidity type, expected Int or Uint."
    case invalidSolidityTypeAddress = "Invalid solidity type address."
    case invalidJsonObjectIdentifier = "JsonObject doesn't have desired identifier"
    case jsonConversionFailed = "JSON conversion to object failed."
    case addDeviceFlowCancelled = "Add device flow cancelled."
    case objectCreationFailed = "Object creation failed."
    case invalidId = "Invalid id."
    case unexpectedState = "Unexpected state."
    case toAddressNotFound = "Unable to find toAddress while executing transaction. Inspect if a correct value is being sent and its not null. Re-submit after verification."
    case signerAddressNotFound = "Access denied due to invalid credentials. Please inspect if the api signer address is not null and is valid."
    case dbExecutionFailed = "DB execution failed."
    case invalidEntityType = "Unable to recognize the API request object sent and so cannot be executed."
    case invalidQRCode = "The QR code does not contain valid data definition. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform"
    case invalidAddressToTransfer = "Invalid address to transfer value. Inspect if a correct value is being sent and its not null."
    case sessionNotAuthorizing = "Session is not authorizing."
    case maxUserValidatedCountReached = "The maximum number of 'authenticating with PIN' attempts has been reached. Please try again a bit later."
    case recoveryPinNotFoundInKeyManager = "recovery pin not found in key manager."
    case rulesNotFound = "Unable to recognize the Rule Name. Please inspect a valid rule name is passed. Ensure its not null and re-submit the request. Visit https://dev.ost.com/platform to know about rule details"
    case invalidAmount = "Amount to do transaction is invalid. Please inspect the amount is not null and is a valid value. Visit https://dev.ost.com/platform to know details about the input datatype."
    case sessionNotFound = "The device doesn't has any active session. Please authorize a session before doing any transaction. Workflow details provided at https://dev.ost.com/platform/docs/sdk/references"
    case callDataFormationFailed = "Calldata formation for executing a transaction failed."
    case transactionFailed = "Transaction failed."
    case resetPinFailed = "Reset Recovery api failed. Either OST server is unavailable temporarily OR The API request object sent cannot be executed. Please inspect the input being sent and re-try. If the problem persists contact support@ost.com"
    case failedFetchRecoveryOwnerAddress = "Failed to get recovery owner address. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later."
    case pricePointNotFound = "Unable to recognize 'PRICE_POINT' details. Ensure the field is not null. For details on supported currencies and token symbols by price point api please vist https://dev.ost.com/platform/docs/api"
    case invalidPricePoint = "Invalid 'PRICE_POINT' details. For details on supported currencies and token symbols by price point api please vist https://dev.ost.com/platform/docs/api"
    case invalidNumber = "Invalid number"
    case invalidExpirationTimeStamp = "Invalid expiration timestamp. Please ensure timestamp is passed in required format. For parameter details please vist https://dev.ost.com/platform/docs/api"
    case requestTimedOut = "Request timed out. This can be intermittent event with a request failing followed by successful one."
    case failedToProcess = "Entity failed to process"
    case samePin = "Old and new pin both are same"
    case conversionFactorNotFound = "Conversion factor not present."
    case btDecimalNotFound = "Decimal value not found"
    case keyNotFound = "Key not found"
    case insufficientData = "Insufficient data"
    case invalidSpendingLimit = "Spending limit provided is invalid. Spending limit should be in atto BT and can not be decimal value. Please inspect the value being sent is correct and not null, rectify and re-submit."
    case unknown = "Unknown error"
    case solidityTypeNotSupported = "Solidity Shar3 type not supported. Supported types are bytes, sting, bool, address, uint."
    
    //API-Errors
    case invalidApiEndPoint = "Invalid Api Endpoint"
    case apiSignatureGenerationFailed = "Api Signature generation failed."
    case sessionApiFailed = "Failed to fetch session information. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later."
    case pinValidationFailed = "Either the entered Pin is same or incorrect."
    case invalidMnemonics = "The 12 word passphrase you provided is incorrect."

    //Generic errors.
    case sdkError = "An internal SDK error has occoured."
    case apiResponseError = "Api responsed with error. Please see error info."
    case tempMessageTextCode = "Something went wrong."
    case userCanceled = "User canceled"
}
