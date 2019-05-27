/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation

@objc public class OstErrorCodes:NSObject {
    @objc public enum OstErrorCode: Int {
        case userNotFound,
        invalidUser,
        userAlreadyActivated,
        userNotActivated,
        userNotActivating,
        deviceNotSet,
        deviceNotAuthorized,
        deviceAuthorized,
        deviceNotRecovering,
        deviceNotRevoking,
        deviceNotAuthorizing,
        wrongDeviceAddress,
        processSameDevice,
        differentOwnerDevice,
        accessControlFailed,
        unableToGetPublicKey,
        encryptFail,
        decryptFail,
        keychainDeleteItemFail,
        keychainAddItemFail,
        generatePrivateKeyFail,
        noPrivateKeyFound,
        mnemonicsNotStored,
        mnemonicsNotFound,
        scryptKeyGenerationFailed,
        seedCreationFailed,
        walletGenerationFailed,
        signTxFailed,
        signatureFailed,
        apiAddressNotFound,
        apiEndpointNotFound,
        userEntityNotFound,
        entityNotAvailable,
        invalidAPIResponse,
        unableToGetSalt,
        unableToChainInformation,
        deviceNotRegistered,
        deviceAlreadyRegistered,
        deviceManagerNotFound,
        userActivationFailed,
        invalidPayload,
        paperWalletNotFound,
        invalidDataDefination,
        recoveryAddressNotFound,
        recoveryOwnerAddressNotFound,
        recoveryOwnerAddressCreationFailed,
        linkedAddressNotFound,
        invalidRecoveryAddress,
        invalidUserId,
        invalidTokenId,
        tokenNotFound,
        signatureGenerationFailed,
        unexpectedError,
        abiEncodeFailed,
        qrReadFailed,
        qrCodeGenerationFailed,
        qrCodeImageGenerationFailed,
        functionNotFoundInABI,
        invalidSolidityTypeInt,
        invalidSolidityTypeAddress,
        invalidJsonObjectIdentifier,
        jsonConversionFailed,
        addDeviceFlowCancelled,
        objectCreationFailed,
        invalidId,
        unexpectedState,
        toAddressNotFound,
        signerAddressNotFound,
        dbExecutionFailed,
        invalidEntityType,
        invalidQRCode,
        invalidAddressToTransfer,
        sessionNotAuthorizing,
        maxUserValidatedCountReached,
        recoveryPinNotFoundInKeyManager,
        rulesNotFound,
        invalidAmount,
        sessionNotFound,
        callDataFormationFailed,
        transactionFailed,
        resetPinFailed,
        failedFetchRecoveryOwnerAddress,
        pricePointNotFound,
        invalidPricePoint,
        invalidNumber,
        invalidExpirationTimeStamp,
        requestTimedOut,
        failedToProcess,
        samePin,
        conversionFactorNotFound,
        btDecimalNotFound,
        keyNotFound,
        insufficientData,
        invalidSpendingLimit,
        unknown,
        solidityTypeNotSupported,
        
        //API-Errors
        invalidApiEndPoint,
        apiSignatureGenerationFailed,
        sessionApiFailed,
        pinValidationFailed,
        invalidMnemonics,

        //React-Native Errors.
        invalidWorkflow,
        invalidJsonString, /* Should replace jsonConversionFailed */
        invalidJsonArray,
        
        //Generic errors.
        sdkError,
        apiResponseError,
        tempMessageTextCode,
        userCanceled;
    }
    @objc public class func getErrorMessage(errorCode:OstErrorCode) -> String {
        switch errorCode {
        case .userNotFound: return "Unable to find this user in your economy. Inspect if a correct value is being sent in user Id field and its not null. Re-submit after verification.";
        case .invalidUser: return "Unable to recognize the user. Please ensure user id is not null and re-submit the request.";
        case .userAlreadyActivated: return "This User is already activated";
        case .userNotActivated: return "This user is not activated yet. Please setup user's wallet to enable their participation in your economy.";
        case .userNotActivating: return "User is not activating";
        case .deviceNotSet: return "Unable to recognize the device. Please setup this device for the user using workflows provided at; https://dev.ost.com/platform/docs/sdk";
        case .deviceNotAuthorized: return "Unable to perform the operation as the device is not authorized. For details on how to authorize a device; please visit https://dev.ost.com/platform/docs/sdk";
        case .deviceAuthorized: return "This Device is already authorized.";
        case .deviceNotRecovering: return "This Device is not in recovering mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .deviceNotRevoking: return "This Device is not in revoking mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .deviceNotAuthorizing: return "Device is not in authorizing mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .wrongDeviceAddress: return "Incorrect device address. Please inspect the value being sent is correct and not null, rectify and re-submit.";
        case .processSameDevice: return "Trying to process same device.";
        case .differentOwnerDevice: return "The device is not registered with the user, so the operation could not be complete. Inspect if a correct; value is being sent and re-submit.";
        case .accessControlFailed: return "Unable to perform the operation on the given resource due to restricted access.";
        case .unableToGetPublicKey: return "Unable to get public key. Please ensure the input is well formed or visit https://dev.ost.com/platform/docs/api for details on accepted datatypes for API parameters.";
        case .encryptFail: return "Error while encrypting data with public key.";
        case .decryptFail: return "Error while decrypting data with private key.";
        case .keychainDeleteItemFail: return "Error while deleting item from keychain.";
        case .keychainAddItemFail: return "Error while adding item in keychain.";
        case .generatePrivateKeyFail: return "Error while generating private key.";
        case .noPrivateKeyFound: return "Private key not found.";
        case .mnemonicsNotStored: return "Unable to store the 12 words mnemonics. Please try again.";
        case .mnemonicsNotFound: return "The 12 words mnemonics you provided is either incorrect or null.";
        case .scryptKeyGenerationFailed: return "Failed to generate SCrypt key.";
        case .seedCreationFailed: return "Failed to generate Recovery key. Inspect if a correct input values required are being sent and re-submit the; request.";
        case .walletGenerationFailed: return "Failed to create wallet. Inspect if a correct input values required are being sent. Please follow the; recovery flow guide on https://dev.ost.com/platform/docs for details on input parameters.";
        case .signTxFailed: return "Unable to sign transaction data with private key. Visit https://dev.ost.com/platform/docs/sdk for detailed SDK references. Please ensure the input is well formed and re-submit the request.";
        case .signatureFailed: return "Unable to sign message with private key. Visit https://dev.ost.com/platform/docs/sdk for detailed SDK references. Please ensure the input is well formed and re-submit the request.";
        case .apiAddressNotFound: return "API address not found.";
        case .apiEndpointNotFound: return "API endpoint not found.";
        case .userEntityNotFound: return "Unable to find this user in your economy. Inspect if a correct value is being sent in user Id field and re-submit the request.";
        case .entityNotAvailable: return "Unable to recognize the API response entity sent and so cannot be executed.";
        case .invalidAPIResponse: return "Unable to recognize the API response object sent and so cannot be executed.";
        case .unableToGetSalt: return "Failed to fetch user salt. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later.";
        case .unableToChainInformation: return "Failed to fetch block-chain information. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later.";
        case .deviceNotRegistered: return "Please ensure the device is 'Registered' for this user with OST platform. Only a registered device can do wallet operations.";
        case .deviceAlreadyRegistered: return "Device is registered.";
        case .deviceManagerNotFound: return "Device manager is not persent. This means either the user activation is in progress or has not started at all. Please ensure user activation workflow is complete successfully.";
        case .userActivationFailed: return "Unable to complete the user activation flow. Inspect if correct input values are being sent, the input is well formed and re-try. If the problem persists contact support@ost.com";
        case .invalidPayload: return "Invalid paylaod to process.";
        case .paperWalletNotFound: return "Paper wallet not found.";
        case .invalidDataDefination: return "The QR code for doing this operation is not well formed. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform ";
        case .recoveryAddressNotFound: return "Recovery address is not set for this user. This address is set during user activation. Please verify the user has been successfully activated.";
        case .recoveryOwnerAddressNotFound: return "Recovery owner address is not set for this user. This address is set during user activation. Please verify the user has been successfully activated.";
        case .recoveryOwnerAddressCreationFailed: return "Recovery owner address creation failed. This address is created during user activation. Please verify the user has been successfully activated.";
        case .linkedAddressNotFound: return "Linked address for user is not set.";
        case .invalidRecoveryAddress: return "Invalid recovery address. Please ensure the recovery address is not null.";
        case .invalidUserId: return "Unable to recognize the user id. Please inspect for what is being sent, rectify and re-submit.";
        case .invalidTokenId: return "Unable to recognize the token id. Please inspect for what is being sent, rectify and re-submit.";
        case .tokenNotFound: return "Incorrect token for your economy. Inspect if a correct value is being sent in token Id field and re-submit the request.";
        case .signatureGenerationFailed: return "Signature generation failed.";
        case .unexpectedError: return "Unexpected error.";
        case .abiEncodeFailed: return "ABI encoding failed.";
        case .qrReadFailed: return "Unable to read QR code data from given image. The QR code might not contain valid data definition. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform";
        case .qrCodeGenerationFailed: return "QR-Code generation failed.";
        case .qrCodeImageGenerationFailed: return "QR-Code image generation failed.";
        case .functionNotFoundInABI: return "Generating ABI encodable values failed.";
        case .invalidSolidityTypeInt: return "Invalid solidity type, expected Int or Uint.";
        case .invalidSolidityTypeAddress: return "Invalid solidity type address.";
        case .invalidJsonObjectIdentifier: return "JsonObject doesn't have desired identifier";
        case .jsonConversionFailed: return "JSON conversion to object failed.";
        case .addDeviceFlowCancelled: return "Add device flow cancelled.";
        case .objectCreationFailed: return "Object creation failed.";
        case .invalidId: return "Invalid id.";
        case .unexpectedState: return "Unexpected state.";
        case .toAddressNotFound: return "Unable to find toAddress while executing transaction. Inspect if a correct value is being sent and its not null. Re-submit after verification.";
        case .signerAddressNotFound: return "Access denied due to invalid credentials. Please inspect if the api signer address is not null and is valid.";
        case .dbExecutionFailed: return "DB execution failed.";
        case .invalidEntityType: return "Unable to recognize the API request object sent and so cannot be executed.";
        case .invalidQRCode: return "The QR code does not contain valid data definition. To know the data definition for QR code based on type of operations please visit https://dev.ost.com/platform";
        case .invalidAddressToTransfer: return "Invalid address to transfer value. Inspect if a correct value is being sent and its not null.";
        case .sessionNotAuthorizing: return "Session is not authorizing.";
        case .maxUserValidatedCountReached: return "The maximum number of 'authenticating with PIN' attempts has been reached. Please try again a bit later.";
        case .recoveryPinNotFoundInKeyManager: return "recovery pin not found in key manager.";
        case .rulesNotFound: return "Unable to recognize the Rule Name. Please inspect a valid rule name is passed. Ensure its not null and re-submit the request. Visit https://dev.ost.com/platform to know about rule details";
        case .invalidAmount: return "Amount to do transaction is invalid. Please inspect the amount is not null and is a valid value. Visit https://dev.ost.com/platform to know details about the input datatype.";
        case .sessionNotFound: return "The device doesn't has any active session. Please authorize a session before doing any transaction. Workflow details provided at https://dev.ost.com/platform/docs/sdk/references";
        case .callDataFormationFailed: return "Calldata formation for executing a transaction failed.";
        case .transactionFailed: return "Transaction failed.";
        case .resetPinFailed: return "Reset Recovery api failed. Either OST server is unavailable temporarily OR The API request object sent cannot be executed. Please inspect the input being sent and re-try. If the problem persists contact support@ost.com";
        case .failedFetchRecoveryOwnerAddress: return "Failed to get recovery owner address. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later.";
        case .pricePointNotFound: return "Unable to recognize 'PRICE_POINT' details. Ensure the field is not null. For details on supported currencies and token symbols by price point api please vist https://dev.ost.com/platform/docs/api";
        case .invalidPricePoint: return "Invalid 'PRICE_POINT' details. For details on supported currencies and token symbols by price point api please vist https://dev.ost.com/platform/docs/api";
        case .invalidNumber: return "Invalid number";
        case .invalidExpirationTimeStamp: return "Invalid expiration timestamp. Please ensure timestamp is passed in required format. For parameter details please vist https://dev.ost.com/platform/docs/api";
        case .requestTimedOut: return "Request timed out. This can be intermittent event with a request failing followed by successful one.";
        case .failedToProcess: return "Entity failed to process";
        case .samePin: return "Old and new pin both are same";
        case .conversionFactorNotFound: return "Conversion factor not present.";
        case .btDecimalNotFound: return "Decimal value not found";
        case .keyNotFound: return "Key not found";
        case .insufficientData: return "Insufficient data";
        case .invalidSpendingLimit: return "Spending limit provided is invalid. Spending limit should be in atto BT and can not be decimal value. Please inspect the value being sent is correct and not null, rectify and re-submit.";
        case .solidityTypeNotSupported: return "Solidity Shar3 type not supported. Supported types are bytes, sting, bool, address, uint.";
            
        //API-Errors
        case .invalidApiEndPoint: return "Invalid Api Endpoint";
        case .apiSignatureGenerationFailed: return "Api Signature generation failed.";
        case .sessionApiFailed: return "Failed to fetch session information. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later.";
        case .pinValidationFailed: return "Either the entered Pin is same or incorrect.";
        case .invalidMnemonics: return "The 12 word passphrase you provided is incorrect.";
            
        //React Native Errors.
        case .invalidWorkflow: return "The workflow is no longer accessible.";
        case .invalidJsonArray: return "JSON conversion to array failed.";
        case .invalidJsonString: return "JSON conversion to object failed.";
            
        //Generic errors.
        case .sdkError: return "An internal SDK error has occoured.";
        case .apiResponseError: return "Api responsed with error. Please see error info.";
        case .tempMessageTextCode: return "Something went wrong.";
        case .userCanceled: return "User canceled";
        case .unknown: return "Unknown error";
        }
    }
    
    @objc public class func getNSErrorCode(errorCode:OstErrorCode) -> Int {
        return errorCode.rawValue + 10000;
    }
    
    @objc public class func getStringErrorCode(errorCode:OstErrorCode) -> String {
        return ("\(errorCode)").snakeCased()!;
    }
}
