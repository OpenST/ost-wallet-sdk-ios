# OST Wallet SDK iOS

## Introduction

Wallet SDK is a mobile application development SDK that enables developers to integrate the functionality of a non-custodial crypto-wallet into consumer applications. The SDK:

- Safely generates and stores keys on the user's mobile device
- Signs Ethereum transactions and data as defined by contracts using EIP-1077
- Enables users to recover access to their Brand Tokens in case the user loses their authorized device</br>



## Support

- iOS version : 9.0 and above (**recommended version 10.3** )
- Swift version: 4.2

## Setup

- Get [Carthage](https://github.com/Carthage/Carthage) by running `brew install carthage` or choose [another installation method](https://github.com/Carthage/Carthage/#installing-carthage)
- Create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Specify OstWalletSdk in [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```
github "ostdotcom/ost-wallet-sdk-ios" "version"
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
$(SRCROOT)/Carthage/Build/iOS/OstWalleSdk.framework
```

- Create `OstWalletSdk.plist` file. Following is the default configurations.

```
<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 <key>BlockGenerationTime</key>
 <integer>3</integer>
 <key>PricePointTokenSymbol</key>
 <string>OST</string>
 <key>PricePointCurrencySymbol</key>
 <string>USD</string>
 <key>RequestTimeoutDuration</key>
 <integer>30</integer>
 <key>PinMaxRetryCount</key>
 <integer>3</integer>
 <key>SessionBufferTime</key>
 <integer>3600</integer>
 </dict>
 </plist>
 ```
 - _BlockGenerationTime_: The time in seconds it takes to mine a block on auxiliary chain.
- _PricePointTokenSymbol_: This is the symbol of base currency. So it's value will be OST.
- _PricePointCurrencySymbol_: It is the symbol of quote currency used in price conversion.
- _RequestTimeoutDuration_: Request timeout in seconds for https calls made by ostWalletSdk.
- _PinMaxRetryCount_: Maximum retry count to get the wallet Pin from user.
- _SessionBufferTime_: Buffer expiration time for session keys in seconds.

## OST Wallet SDK APIs
To use Ost wallet sdk use `import OstWalletSdk`

### Initialize the SDK

The SDK can be initialized by calling the `initialize()` API which
initializes all the required instances and runs migrations of local databases.

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try OstWalletSdk.initialize(apiEndPoint: <KIT_API_ENDPOINT>)
     } catch let ostError {

     }
     return true
}
```

### Set up the device

The `setupDevice` API should be called each time the application is launched to confirm that the current device is in the `registered` state and therefore able to call the OST Platform APIs.<br/><br/>
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
&nbsp;_spendingLimitInWei: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.activateUser(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    spendingLimitInWei: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkflowDelegate
    )
```

### Authorize session
A session is a period of time during which a sessionKey is authorized to sign transactions under a pre-set limit on behalf of the user.

The device manager, which controls the tokens, authorizes sessions. <br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_spendingLimitInWei: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.addSession(
    userId: String,
    spendingLimitInWei: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkflowDelegate
    )
```

### Execute Transaction
A transaction where Brand Tokens are transferred from a user to another actor within the Brand Token economy are signed using `sessionKey` if there is an active session. In the absence of an active session, a new session is authorized.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_tokenHolderAddresses: Token holder addresses of amount receiver_<br/>
&nbsp;_amounts: Amounts corresponding to tokenHolderAddresses in wei to be transfered_<br/>
&nbsp;_transactionType: OstExecuteTransactionType value_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.executeTransaction(
    userId: String,
    tokenHolderAddresses: [String],
    amounts: [String],
    transactionType: OstExecuteTransactionType,
    delegate: OstWorkflowDelegate
    )
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
```Swift
/// Inform SDK user that entered pin is validated.
/// Developers should dismiss pin dialog on this callback.
/// - Parameter userId: Id of user whose pin and passphrase prefix has been validated.
func pinValidated(_ userId: String)
```
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

## Reference

For a sample implementation, please see the [Demo App](https://github.com/ostdotcom/ios-demo-app/tree/develop)

There are other references are listed below:

- [OstWorkflowContext](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstWorkflowContext.swift)

- [OstContextEntity](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstContextEntity.swift)

- [OstError](https://github.com/ostdotcom/ost-wallet-sdk-ios/tree/develop/OstWalletSdk/Errors)
