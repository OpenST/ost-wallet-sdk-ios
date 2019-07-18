# OST Wallet SDK iOS

## Introduction

Wallet SDK is a mobile application development SDK that enables developers to integrate the functionality of a non-custodial crypto-wallet into consumer applications. The SDK:

- Safely generates and stores keys on the user's mobile device
- Signs Ethereum transactions and data as defined by contracts using EIP-1077
- Enables users to recover access to their Brand Tokens in case the user loses their authorized device</br>



## Support

- iOS version : 9.0 and above (**recommended version 10.3** )
- Swift version: 4.2

## Dependencies
We use open-source code from the projects listed below. The `Setup` section below provides instructions on adding the packages to your code. 
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)
- [EthereumKit](https://github.com/D-Technologies/EthereumKit)
- [FMDB](https://github.com/ccgus/fmdb)
- [BigInt](https://github.com/attaswift/BigInt)
- [TrustKit](https://github.com/datatheorem/TrustKit)


## Setup

- Get [Carthage](https://github.com/Carthage/Carthage) by running `brew install carthage` or choose [another installation method](https://github.com/Carthage/Carthage/#installing-carthage)
- Create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Specify OstWalletSdk in [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```
github "ostdotcom/ost-wallet-sdk-ios" == 2.2.3
```

- Run `carthage update --platform iOS`
- A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Open application target, under `General` tab, drag the built `OstWalletSdk.framework` binary from `Carthage/Build/iOS` into `Linked Frameworks and Libraries` section.
- On the application targets’ `Build Phases` settings tab, click the _+_ icon and choose `New Run Script Phase`. Add the following command

```sh
/usr/local/bin/carthage copy-frameworks
```

- Click the + under `Input Files` and add an entry for each framework:

```
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
$(SRCROOT)/Carthage/Build/iOS/BigInt.framework
$(SRCROOT)/Carthage/Build/iOS/CryptoEthereumSwift.framework
$(SRCROOT)/Carthage/Build/iOS/CryptoSwift.framework
$(SRCROOT)/Carthage/Build/iOS/EthereumKit.framework
$(SRCROOT)/Carthage/Build/iOS/FMDB.framework
$(SRCROOT)/Carthage/Build/iOS/SipHash.framework
$(SRCROOT)/Carthage/Build/iOS/TrustKit.framework
$(SRCROOT)/Carthage/Build/iOS/OstWalletSdk.framework
```

- Create `OstWalletSdk.plist` file. Following is the default configurations.

```
<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 <key>BlockGenerationTime</key>
 <integer>3</integer>
 <key>PricePointCurrencySymbol</key>
 <string>USD</string>
 <key>RequestTimeoutDuration</key>
 <integer>30</integer>
 <key>PinMaxRetryCount</key>
 <integer>3</integer>
 <key>SessionBufferTime</key>
 <integer>3600</integer>
 <key>UseSeedPassword</key>
 <false/>
 </dict>
 </plist>
 ```
- _BlockGenerationTime_: The time in seconds it takes to mine a block on auxiliary chain.
- _PricePointCurrencySymbol_: It is the symbol of quote currency used in price conversion.
- _RequestTimeoutDuration_: Request timeout in seconds for https calls made by ostWalletSdk.
- _PinMaxRetryCount_: Maximum retry count to get the wallet Pin from user.
- _SessionBufferTime_: Buffer expiration time for session keys in seconds.
- _UseSeedPassword_: Uses mnemonics and password to generate seed.

**These configurations are MANDATORY for successful operation. Failing to set them will significantly impact usage.**

## Enable FaceID Authentication
To authenticate user using FaceID on devices that support it, please add [NSFaceIDUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsfaceidusagedescription) to your application's `Info.plist`.

## OST Wallet SDK APIs
To use Ost wallet sdk use `import OstWalletSdk`

### Initialize the SDK

The SDK can be initialized by calling the `initialize()` API which
initializes all the required instances and runs migrations of local databases.

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try OstWalletSdk.initialize(apiEndPoint: <OST_PLATFORM_API_ENDPOINT>)
     } catch let ostError {

     }
     return true
}
```

### Set up the device

The `setupDevice` API should be called after user login or signup is successful.

Once the user is logged in, then `setupDevice` should be called every time the app launches, this ensures that the current device is registered before communicating with OST Platform server.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_tokenId: Token id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.setupDevice(
    userId: String,
    tokenId: String,
    delegate: OstWorkflowDelegate
    )
```    

### Activate the user

User activation refers to the deployment of smart-contracts that form the user's Brand Token wallet. An activated user can engage with a Brand Token economy.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_pin: User Pin_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in atto BT_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.activateUser(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    spendingLimit: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkflowDelegate
    )
```

### Authorize session
A session is a period of time during which a sessionKey is authorized to sign transactions under a pre-set limit on behalf of the user.

The device manager, which controls the tokens, authorizes sessions. <br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in atto BT_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.addSession(
    userId: String,
    spendingLimit: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkflowDelegate
    )
```

### Execute a transaction
A transaction where Brand Tokens are transferred from a user to another actor within the Brand Token economy are signed using `sessionKey` if there is an active session. In the absence of an active session, a new session is authorized.<br/><br/>

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_tokenHolderAddresses: Token holder addresses of amount receiver_<br/>
&nbsp;_amounts: Amounts corresponding to tokenHolderAddresses in wei to be transfered_<br/>
&nbsp;_transactionType: [OstExecuteTransactionType value](OstWalletSdk/Workflows/OstExecuteTransaction.swift#L14)_<br/>
&nbsp;_meta: meta data of transaction to be associated_<br/>
Example:-
```json
                           {"name": "transaction name",
                           "type": "user-to-user",
                           "details": "like"}
```
&nbsp;_options: Map containing options of transactions_<br/>
Example:-
```json
                           {"currency_code": "USD",
                           "wait_for_finalization": true}
```
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.executeTransaction(
        userId: String,
        tokenHolderAddresses: [String],
        amounts: [String],
        transactionType: OstExecuteTransactionType,
        meta: [String: String],
        options: [String: Any],
        delegate: OstWorkflowDelegate)
```

### Get Mnemonic Phrase

The mnemonic phrase represents a human-readable way to authorize a new device. This phrase is 12 words long.
 <br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.getDeviceMnemonics(
    userId: String,
    delegate: OstWorkflowDelegate
    )
```

### Add a device using mnemonics

A user that has stored their mnemonic phrase can enter it into an appropriate user interface on a new mobile device and authorize that device to be able to control their Brand Tokens.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_mnemonics: Array of mnemonics_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.authorizeCurrentDeviceWithMnemonics(
    userId: String,
    mnemonics: [String],
    delegate: OstWorkflowDelegate
)
```

### Generate a QR Code

A developer can use this method to generate a QR code that displays the information pertinent to the mobile device it is generated on. Scanning this QR code with an authorized mobile device will result in the new device being authorized.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>

```Swift
OstWalletSdk.getAddDeviceQRCode(
    userId: String
    ) throws -> CIImage?
```

### Perform QR action

QR codes can be used to encode transaction data for authorizing devices, making purchases via webstores, etc. This method can be used to process the information scanned off a QR code and act on it.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_payload: Json string of payload is scanned by QR-Code._<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.performQRAction(
    userId: String,
    payload: String,
    delegate: OstWorkflowDelegate
    )
```

### Reset a User's PIN

The user's PIN is set when activating the user. This method supports re-setting a PIN and re-creating the recoveryOwner as part of that.
<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_oldUserPin: Users old Pin_<br/>
&nbsp;_newUserPin: Users new Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.resetPin(
    userId: String,
    passphrasePrefix: String,
    oldUserPin: String,
    newUserPin: String,
    delegate: OstWorkflowDelegate
    )
```

### Initialize Recovery

A user can control their Brand Tokens using their authorized devices. If they lose their authorized device, they can recover access to their BrandTokens by authorizing a new device via the recovery process .<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_recoverDeviceAddress: Device address which wants to recover_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_userPin: Users Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>


```Swift
OstWalletSdk.initiateDeviceRecovery(
    userId: String,
    recoverDeviceAddress: String,
    userPin: String,
    passphrasePrefix: String,
    delegate: OstWorkflowDelegate
    )
```

###  Abort Device Recovery

To abort initiated device recovery.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_userPin: Users Pin_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.abortDeviceRecovery(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    delegate: OstWorkflowDelegate)
```

###  Revoke Device

To revoke device access.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_deviceAddressToRevoke: Device address to revoke_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.revokeDevice(
    userId: String,
    deviceAddressToRevoke: String,
    delegate: OstWorkflowDelegate) 
```

###  Update Biometric Preference

This method can be used to enable or disable the biometric.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_enable: Preference to use biometric_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.updateBiometricPreference(
    userId: String,
    enable: Bool,
    delegate: OstWorkflowDelegate) 
```

### Get User 
Get user entity for given userId<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_returns: User entity_<br/>
```Swift
OstWalletSdk.getUser(userId: String) 
```

### Get Token 
Get token entity for given tokenId<br/><br/>
**Parameters**<br/>
&nbsp;_tokenId: Token id provided by application server_<br/>
&nbsp;_returns: Token entity_<br/>
```Swift
OstWalletSdk.getToken(tokenId: String) 
```

### Get Current Device
Get current device of user<br/><br/>
```Swift
let user: OstUser = OstWalletSdk.getUser(userId: String)
let device: OstCurrentDevice = user.getCurrentDevice()
```

### Get Biometric preference
Get biometric preference for user<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_returns: Boolean_<br/>
```Swift
OstWalletSdk.isBiometricEnabled(userId: String) 
```

## Workflow Callbacks

```Swift
/// Register device passed as parameter.
///
/// - Parameters:
///   - apiParams: Register Device API parameters.
///   - delegate: To pass response.
func registerDevice(
        _ apiParams: [String: Any],
        delegate: OstDeviceRegisteredDelegate
        )
```
| Argument | Description |
|---|---|
| **apiParams** <br> **[String: Any]**	|	Device information for registration	|
| **delegate** <br> **OstDeviceRegisteredDelegate**	| **delegate.deviceRegistered(_ apiResponse: [String: Any] )** should be called to pass the newly created device entity back to SDK. <br>In case data if there is some issue while registering the device then the current workflow should be canceled  by calling **delegate.cancelFlow()** |

```Swift
/// Pin needed to check the authenticity of the user.
/// Developers should show pin dialog on this callback.
///
/// - Parameters:
///   - userId: User id whose passphrase prefix and pin required.
///   - delegate: To pass pin
func getPin(
        _ userId: String,
        delegate: OstPinAcceptDelegate
        )
```

| Argument | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user |
| **delegate** <br> **OstPinAcceptDelegate**	| **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** should be called to pass the PIN back to SDK. <br> For some reason if the developer wants to cancel the current workflow they can do it by calling **delegate.cancelFlow()**|



```Swift    
/// Inform SDK user about invalid pin.
/// Developers should show invalid pin error and ask for pin again on this callback.
///
/// - Parameters:
///   - userId: User id whose passphrase prefix and pin validattion failed.
///   - delegate: To pass another pin.
func invalidPin(
        _ userId: String,
        delegate: OstPinAcceptDelegate
        )
```

| Argument | Description |
|---|---|
| **userId** <br> **String**	|	Unique identifier of the user	|
| **delegate** <br> **OstPinAcceptDelegate**	| **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** should be called to again pass the PIN back to SDK. <br> For some reason if the developer wants to cancel the current workflow they can do it by calling **delegate.cancelFlow()** |



```Swift
/// Inform SDK user that entered pin is validated.
/// Developers should dismiss pin dialog on this callback.
/// - Parameter userId: Id of user whose pin and passphrase prefix has been validated.
func pinValidated(_ userId: String)
```
| Argument | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user |



```Swift
/// Inform SDK user the the flow is complete.
///
/// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
/// - Parameter ostContextEntity: Status of the flow.
func flowComplete(
        workflowContext: OstWorkflowContext,
        ostContextEntity: OstContextEntity
        )
```
| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	|	Information about the workflow	|
| **ostContextEntity** <br> **OstContextEntity**	| Information about the entity |



```Swift
/// Inform SDK user that flow is interrupted with errorCode.
/// Developers should dismiss pin dialog (if open) on this callback.
///
/// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
/// - Parameter ostError: Reason of interruption.
func flowInterrupted(
        workflowContext: OstWorkflowContext,
        error: OstError
        )
```
| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	| Information about the workflow |
| **ostError** <br> **OstError**	| ostError object will have details about the error that interrupted the flow |

```Swift

/// Verify data which is scanned from QR-Code
///
/// - Parameters:
///   - workflowContext: OstWorkflowContext
///   - ostContextEntity: OstContextEntity
///   - delegate: callback
func verifyData(
        workflowContext: OstWorkflowContext,
        ostContextEntity: OstContextEntity,
        delegate: OstValidateDataDelegate
        )
```
| Argument | Description |
|---|---|
| **workflowContext** <br> **OstWorkflowContext**	| Information about the current workflow during which this callback will be called	|
| **ostContextEntity** <br> **OstContextEntity**	| Information about the entity |
| **delegate** <br> **OstValidateDataDelegate**	| **delegate.dataVerified()** should be called if the data is verified successfully. <br>In case data is not verified the current workflow should be canceled by calling **delegate.cancelFlow()**|

```Swift
/// Acknowledge user about the request which is going to make by SDK.
///
/// - Parameters:
///   - workflowContext: OstWorkflowContext
///   - ostContextEntity: OstContextEntity
func requestAcknowledged(
        workflowContext: OstWorkflowContext,
        ostContextEntity: OstContextEntity
        )
```
| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	| Information about the workflow	|
| **ostContextEntity** <br> **OstContextEntity**	| Information about the entity |


## OST JSON APIs

### User Balance

Api to get user balance. Balance of only current logged-in user can be fetched.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstJsonApi.getBalance(
    forUserId userId: String,
    delegate: OstJsonApiDelegate) 
```

### Price Points

Api to get price points. 
It will provide latest conversion rates of base token to fiat currency.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstJsonApi.getPricePoint(
    forUserId userId: String,
    delegate: OstJsonApiDelegate) 
```

### Balance With Price Points

Api to get user balance and price points. Balance of only current logged-in user can be fetched.
It will also provide latest conversion rates of base token to fiat currency.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstJsonApi.getBalanceWithPricePoint(
    forUserId userId: String,
    delegate: OstJsonApiDelegate) 
```

### Transactions

Api to get user transactions. Transactions of only current logged-in user can be fetched.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_requestPayload: request payload. Such as next-page payload, filters etc._<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstJsonApi.getTransaction(
    forUserId userId: String,
    params: [String: Any]?,
    delegate: OstJsonApiDelegate) 
```

### Pending Recovery

Api to get pending recovery.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstJsonApi.getPendingRecovery(
    forUserId userId: String,
    delegate: OstJsonApiDelegate) 
```
## Json Api Response Delegates

```Swift
/// Success callback for API
///
/// - Parameter data: Success API response
func onOstJsonApiSuccess(data:[String:Any]?);
```
| Argument | Description |
|---|---|
| **data** <br> **[String: Any]?**	|	Json api success response	|


```Swift
/// Failure callback for API
///
/// - Parameters:
///   - error: OstError
///   - errorData: Failure API response
func onOstJsonApiError(error:OstError?, errorData:[String:Any]?);
```
| Argument | Description |
|---|---|
| **error** <br> **OstError?**	|	ostError object will have details about the error that interrupted the flow	|
| **data** <br> **[String: Any]?**	|	Json api failure response	|

## Reference

For a sample implementation, please see the [Demo App](demo-app)

There are other references are listed below:

- [OstWorkflowContext](OstWalletSdk/Workflows/OstContext/OstContextEntity.swift)

- [OstContextEntity](OstWalletSdk/Workflows/OstContext/OstWorkflowContext.swift)

- [OstError](OstWalletSdk/Errors)
