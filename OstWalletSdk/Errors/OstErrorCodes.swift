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
        
        case userAlreadyActivated,
        userNotActivated,
        deviceNotSet,
        deviceNotAuthorized,
        wrongDeviceAddress,
        
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
        paperWalletNotFound,
        recoveryOwnerAddressNotFound,
        recoveryOwnerAddressCreationFailed,
        linkedAddressNotFound,
        invalidRecoveryAddress,
        invalidUserId,
        invalidTokenId,
        signatureGenerationFailed,
        abiEncodeFailed,
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
        userCanceled,
        
        //New
        invalidAddDeviceAddress,
        invalidRecoverDeviceAddress,
        invalidRevokeDeviceAddress,
        deviceCanNotBeAuthorized,
        invalidUserPassphrase,
        invalidNewUserPassphrase,
        invalidPassphrasePrefix,
        saltApiFailed,
        
        noPendingRecovery,
		
		invaldApiSignerAddress,
		invalidSignature,
		
        
        //NEW - CONFIGURATION
        invalidBlockGenerationTime,
        invalidPinMaxRetryCount,
        invalidPricePointCurrencySymbol,
        invalidRequestTimeoutDuration,
        invalidSessionBufferTime,
        invalidNoOfSessionsOnActivateUser;
        
        //Deprecated
        @available(*, deprecated, message: "userNotActivating has been deprecated and is not thrown anymore.")
        case userNotActivating;
        @available(*, deprecated, message: "deviceNotRecovering has been deprecated and is not thrown anymore.")
        case deviceNotRecovering;
        @available(*, deprecated, message: "deviceNotRevoking has been deprecated and is not thrown anymore.")
        case deviceNotRevoking;
        @available(*, deprecated, message: "deviceNotAuthorizing has been deprecated and is not thrown anymore.")
        case deviceNotAuthorizing;
        @available(*, deprecated, message: "invalidUser has been deprecated and is not thrown anymore.")
        case invalidUser;
        @available(*, deprecated, message: "userNotFound has been deprecated and is not thrown anymore. Use invalidUserId instead.")
        case userNotFound;
        @available(*, deprecated, message: "processSameDevice has been deprecated and is not thrown anymore. Use wrongDeviceAddress instead.")
        case processSameDevice;
        @available(*, deprecated, message: "invalidPayload has been deprecated and is not thrown anymore.")
        case invalidPayload;
        @available(*, deprecated, message: "tokenNotFound has been deprecated and is not thrown anymore. Use invalidTokenId instead.")
        case tokenNotFound;
        @available(*, deprecated, message: "deviceAuthorized has been deprecated and is not thrown anymore. Use invalidTokenId instead.")
        case deviceAuthorized;
        @available(*, deprecated, message: "deviceAuthorized has been deprecated")
        case differentOwnerDevice;
        @available(*, deprecated, message: "qrReadFailed has been deprecated")
        case qrReadFailed;
        @available(*, deprecated, message: "unexpectedError has been deprecated. Use sdkError instead.")
        case unexpectedError;
        @available(*, deprecated, message: "recoveryAddressNotFound has been deprecated. Use sdkError instead.")
        case recoveryAddressNotFound;
        @available(*, deprecated, message: "invalidDataDefination has been deprecated")
        case invalidDataDefination;
        @available(*, deprecated, message: "tempMessageTextCode has been deprecated")
        case tempMessageTextCode;
    }
    
    @objc public class func getErrorMessage(errorCode:OstErrorCode) -> String {
        switch errorCode {
        case .userNotFound: return "Unable to find this user in your economy. Inspect if a correct value is being sent in user Id field and its not null. Re-submit after verification.";
        case .invalidUser: return "Unable to recognize the user. Please ensure user id is not null and re-submit the request.";
        case .userAlreadyActivated: return "This User is already activated";
        case .userNotActivated: return "This user is not activated yet. Please setup user's wallet to enable their participation in your economy.";
        case .deviceNotSet: return "Unable to recognize the device. Please setup this device for the user using workflows provided at; https://dev.ost.com/platform/docs/sdk";
        case .deviceNotAuthorized: return "Unable to perform the operation as the device is not authorized. For details on how to authorize a device; please visit https://dev.ost.com/platform/docs/sdk";
        
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
            
        //New
        case .invalidAddDeviceAddress:
            return "Invalid add device address. Please ensure the input is well formed or visit https://dev.ost.com/platform/docs/api for details on accepted datatypes for API parameters.";
        case .invalidRecoverDeviceAddress:
            return "Invalid device address. This address can not be recovered.";
        case .invalidRevokeDeviceAddress:
            return "Unable to recognize revoke device address. Please ensure you are not sending a null value and re-submit the request.";
        case .invalidUserPassphrase:
            return "The 6 digit PIN you entered is not correct.";
        case .invalidPassphrasePrefix:
            return "Unable to recognize the Passphrase prefix. Please ensure Passphrase prefix is not null or it's string length is not less than 30. ";
        case .invalidNewUserPassphrase:
            return "The new 6 digit PIN you entered is not correct.";
        case .saltApiFailed:
            return "Failed to fetch user salt. Either OST server is unavailable temporarily OR your connection is going idle. Check your connection and re-submit the request a bit later.";
            
        case .invalidBlockGenerationTime:
            return "Invalid configuration 'BlockGenerationTime'. It must be an Integer greater than zero";
        case .invalidPinMaxRetryCount:
            return "Invalid configuration 'PinMaxRetryCount'. It must be an Integer greater than zero";
        case .invalidPricePointCurrencySymbol:
            return "Unable to recognize 'PricePointCurrencySymbol'. For details on how supported currencies please vist https://dev.ost.com/platform/docs/api ";
        case .invalidRequestTimeoutDuration:
            return "Invalid configuration 'RequestTimeoutDuration'. It must be Integer greater than zero.";
        case .invalidSessionBufferTime:
            return "Invalid configuration 'SessionBufferTime'. It must be long greater than or equal to zero";
        case .invalidNoOfSessionsOnActivateUser:
            return "Invalid configuration 'NoOfSessionsOnActivateUser'. It must be Integer greater than zero and less than six";

        case .noPendingRecovery:
            return "Could not find any pending device recovery request. For details on how to check the status of the recovery please vist https://dev.ost.com/platform/docs/sdk ";
        case .deviceCanNotBeAuthorized:
            return "Unable to authorize this device. Please ensure the device is 'Registered' for this user with OST platform. Only a registered device can be authorized.";
            
		case .invaldApiSignerAddress:
			return "Incorrect Api signer address. Please inspect the value being sent is correct and not null, rectify and re-submit.";

		case .invalidSignature:
			return "The QR code does not contain valid signature.";

            
            
        ///Deprecated
        case .userNotActivating: return "User is not activating";
        case .deviceNotRecovering: return "This Device is not in recovering mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .deviceNotRevoking: return "This Device is not in revoking mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .deviceNotAuthorizing: return "Device is not in authorizing mode. Please ensure you are checking the status of a correct device. If the problem persists contact support@ost.com";
        case .deviceAuthorized: return "This Device is already authorized.";
        }
    }
    
    @objc public class func getNSErrorCode(errorCode:OstErrorCode) -> Int {
        return errorCode.rawValue + 10000;
    }
    
    @objc public class func getStringErrorCode(errorCode:OstErrorCode) -> String {
        switch errorCode{
        case .userAlreadyActivated: return "USER_ALREADY_ACTIVATED";
        case .userNotActivated: return "USER_NOT_ACTIVATED";
        
            
        //---------------- Done till here ----------------//
        case .userEntityNotFound: return "INVALID_USER_ID";
        case .scryptKeyGenerationFailed: return "GENERATE_PRIVATE_KEY_FAIL";
        case .deviceNotSet: return "DEVICE_NOT_SETUP";
        case .deviceNotAuthorized: return "DEVICE_UNAUTHORIZED";
        case .wrongDeviceAddress: return "INVALID_DEVICE_ADDRESS";
        case .seedCreationFailed: return "GENERATE_PRIVATE_KEY_FAIL";
        case .walletGenerationFailed: return "GENERATE_PRIVATE_KEY_FAIL";
        case .signTxFailed: return "FAILED_TO_SIGN_DATA";
        case .signatureFailed: return "FAILED_TO_SIGN_DATA";
        case .apiAddressNotFound: return "INVALID_API_END_POINT";
        case .apiEndpointNotFound: return "INVALID_API_END_POINT";
        case .invalidAPIResponse: return "INVALID_API_RESPONSE";
        case .unableToGetSalt: return "INVALID_API_RESPONSE";
        case .paperWalletNotFound: return "WORKFLOW_FAILED";
        case .recoveryOwnerAddressCreationFailed: return "GENERATE_PRIVATE_KEY_FAIL";
        case .invalidRecoveryAddress: return "INVALID_RECOVERY_ADDRESS";
        case .invalidUserId: return "INVALID_USER_ID";
        case .invalidTokenId: return "INVALID_TOKEN_ID";
        case .signatureGenerationFailed: return "FAILED_TO_SIGN_DATA";
        case .abiEncodeFailed: return "FAILED_TO_SIGN_DATA";
        case .jsonConversionFailed: return "INVALID_JSON_STRING";
        case .signerAddressNotFound: return "FAILED_TO_SIGN_DATA";
        case .invalidQRCode: return "INVALID_QR_CODE";
        case .invalidAddressToTransfer: return "INVALID_ADDRESS_TO_TRANSFER";
        case .maxUserValidatedCountReached: return "MAX_PASSPHRASE_VERIFICATION_LIMIT_REACHED";
        case .rulesNotFound: return "RULES_NOT_FOUND";
        case .invalidAmount: return "INVALID_AMOUNT";
        case .sessionNotFound: return "SESSION_NOT_FOUND";
        case .transactionFailed: return "WORKFLOW_FAILED";
        case .resetPinFailed: return "WORKFLOW_FAILED";
        case .invalidPricePoint: return "INVALID_PRICE_POINT";
        case .invalidExpirationTimeStamp: return "INVALID_SESSION_EXPIRY_TIME";
        case .requestTimedOut: return "POLLING_TIMEOUT";
        case .failedToProcess: return "WORKFLOW_FAILED";
        case .invalidSpendingLimit: return "INVALID_SESSION_SPENDING_LIMIT";
        
        //API-Errors
        case .invalidApiEndPoint: return "INVALID_API_END_POINT";
        case .apiSignatureGenerationFailed: return "FAILED_TO_SIGN_DATA";
        case .invalidMnemonics: return "INVALID_MNEMONICS";
        
        //React-Native Errors.
        case .invalidWorkflow: return "INVALID_WORKFLOW";
        case .invalidJsonString: return "INVALID_JSON_STRING";
        case .invalidJsonArray: return "INVALID_JSON_ARRAY";
        
        //Generic errors.
        case .sdkError: return "SDK_ERROR";
        case .apiResponseError: return "API_RESPONSE_ERROR";
        case .userCanceled: return "WORKFLOW_CANCELLED";
        
        //New
        case .invalidRecoverDeviceAddress: return "INVALID_RECOVER_DEVICE_ADDRESS";
        case .invalidRevokeDeviceAddress: return "INVALID_REVOKE_DEVICE_ADDRESS";
        case .deviceCanNotBeAuthorized: return "DEVICE_CAN_NOT_BE_AUTHORIZED";
        case .invalidUserPassphrase: return "INVALID_USER_PASSPHRASE";
        case .invalidNewUserPassphrase: return "INVALID_NEW_USER_PASSPHRASE";
        case .invalidPassphrasePrefix: return "INVALID_PASSPHRASE_PREFIX";
        case .noPendingRecovery: return "NO_PENDING_RECOVERY";
		case .invaldApiSignerAddress: return "INVALID_API_SIGNER_ADDRESS";
		case .invalidSignature: return "INVALID_SIGNATURE";

        //NEW - CONFIGURATION
        case .invalidBlockGenerationTime: return "INVALID_BLOCK_GENERATION_TIME";
        case .invalidPinMaxRetryCount: return "INVALID_PIN_MAX_RETRY_COUNT";
        case .invalidPricePointCurrencySymbol: return "INVALID_PRICE_POINT_CURRENCY_SYMBOL";
        case .invalidRequestTimeoutDuration: return "INVALID_REQUEST_TIMEOUT_DURATION";
        case .invalidSessionBufferTime : return "INVALID_SESSION_BUFFER_TIME";
        case .invalidNoOfSessionsOnActivateUser: return "INVALID_NO_OF_SESSIONS_ON_ACTIVATE_USER";
            
        ///Deprecated
        case .deviceAuthorized: return "DEVICE_AUTHORIZED";
        case .userNotFound: return "USER_NOT_FOUND";
        case .processSameDevice: return "PROCESS_SAME_DEVICE";
        case .invalidPayload: return "INVALID_PAYLOAD";
        case .invalidDataDefination: return "INVALID_DATA_DEFINATION";
        case .tokenNotFound: return "TOKEN_NOT_FOUND";
        case .userNotActivating: return "USER_NOT_ACTIVATING" ;
        case .deviceNotRecovering: return "DEVICE_NOT_RECOVERING" ;
        case .deviceNotRevoking: return "DEVICE_NOT_REVOKING";
        case .deviceNotAuthorizing: return "DEVICE_NOT_AUTHORIZING";
        case .invalidUser: return "INVALID_USER";
        case .tempMessageTextCode: return "TEMP_MESSAGE_TEXT_CODE";
        case .qrReadFailed: return "QR_READ_FAILED";
        case .unexpectedError: return "UNEXPECTED_ERROR";
        ///TODO - move them.
        case .mnemonicsNotFound: return "MNEMONICS_NOT_FOUND";
        case .unableToChainInformation: return "UNABLE_TO_CHAIN_INFORMATION";
        case .deviceNotRegistered: return "DEVICE_NOT_REGISTERED";
        case .deviceAlreadyRegistered: return "DEVICE_ALREADY_REGISTERED";
        case .userActivationFailed: return "WORKFLOW_FAILED";
        case .qrCodeGenerationFailed: return "QR_CODE_GENERATION_FAILED";
        case .qrCodeImageGenerationFailed: return "QR_CODE_IMAGE_GENERATION_FAILED";
        case .functionNotFoundInABI: return "FUNCTION_NOT_FOUND_IN_A_B_I";
        case .sessionNotAuthorizing: return "SESSION_NOT_AUTHORIZING";
        case .invalidNumber: return "INVALID_NUMBER";
        case .samePin: return "SAME_PIN";
        case .keyNotFound: return "KEY_NOT_FOUND";
        case .insufficientData: return "INSUFFICIENT_DATA";
        case .sessionApiFailed: return "SESSION_API_FAILED";
        case .pinValidationFailed: return "PIN_VALIDATION_FAILED";
        case .saltApiFailed: return "SALT_API_FAILED";
        case .invalidAddDeviceAddress: return "INVALID_ADD_DEVICE_ADDRESS";
        case .addDeviceFlowCancelled: return "ADD_DEVICE_FLOW_CANCELLED";
        default:
            return "SDK_ERROR";
        }
    }
}
