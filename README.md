# ost-client-ios-sdk

## Introduction

Wallet SDK is a mobile application development SDK that enables our partner companies to
- Key Management
- Safely generate and store keys on the mobile device
- Encrypt the wallet keys.
- Sign ethereum transactions and data as defined by contracts using EIP-1077.
- Signed transactions needed for activities such as adding, authorizing and removing keys.
- Signed data is needed to execute actions on the blockchain.


These digital signatures ensure that users have complete control of there tokens and these tokens can only be transferred with their explicit or implicit consent.
    
## Support

- iOS version : 9.0 and above (**recommended version 10.3** )
- Swift version: 4.2

## Quick Setup

- Get [Carthage](https://github.com/Carthage/Carthage) by running `brew install carthage` or choose [another installation method](https://github.com/Carthage/Carthage/#installing-carthage)
- Create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Specify OstWalletSdk in [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```
github "ostdotcom/ost-wallet-sdk-ios" "v0.1.0-beta.1"
```

- Run `carthage update --platform iOS`
- A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Open application target, under `General` tab, drag the built `OstWalletSdk.framework` binary from `Carthage/Build/iOS` into `Linked Frameworks and Libraries` section.
- On your application targets’ `Build Phases` settings tab, click the _+_ icon and choose `New Run Script Phase`. Add the following command

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

## OstWalletSdk apis

To use Ost wallet sdk use `import OstWalletSdk`

### Initialize

To get started with the SDK, you must first initialize SDK by calling _initialize()_ api.
It initializes all the required instances and run migrations of db. 
        
```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try OstWalletSdk.initialize(apiEndPoint: <KIT_API_ENDPOINT>)
     } catch let ostError {
           
     }
     return true
}
```
    
### Setup Device

After Initialize, setupDevice api should be called everytime the app launches.
It ensures current device is in registered state before calling kit apis.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_tokenId: Token id provided by appicationn server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>
 
```Swift
OstWalletSdk.setupDevice(
    userId: String,
    tokenId: String,
    delegate: OstWorkflowDelegate
    )
```    
     
### Activate User

It authorizes the registered device and activate the user.
It makes user eligible to do device operations and transactions.<br/><br/>
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
                     
### Add Session

To add new session to device manager.
Will be used when there are no current session available to do transactions.<br/><br/>
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

To execute Rule.<br/><br/>
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

### Get Device Mnemonics

To get device mnemonics( 12 words used to generate wallet) of the current device.
Mnemonics will be used to add new device incase device is lost<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstWalletSdk.getDeviceMnemonics(
    userId: String,
    delegate: OstWorkflowDelegate
    )
```

### Authorize Current Device With Mnemonics

It authorizes current device using mnemonics provided.
Using mnemonics it generates wallet key to add new current device.<br/><br/>
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

### Get QR-Code To Add Device

Getter method which return QR-Code CIImage for add device.
Use this methods to get QR-Code of current device to be added from authorized device.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>

```Swift
OstWalletSdk.getAddDeviceQRCode(
    userId: String
    ) throws -> CIImage?
```

### Perform QR Action

To perform operations based on QR data provided.
Through QR, Add device and transaction operations can be performed.<br/><br/>
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

### Reset Pin

To update current Pin with new Pin.<br/><br/>
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

###  Initiate Device Recovery

To recover authorized device which could be misplaced or no more in use.<br/><br/>
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
/// A callback that triggers when pin validation failed.
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
/// A callback that informs application that pin has been validated successfully.
/// Developers should dismiss pin dialog on this callback.
/// - Parameter userId: Id of user whose pin and passphrase prefix has been validated.
func pinValidated(_ userId: String)
```
```Swift
/// Informs application the the flow is complete.
///
/// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
/// - Parameter ostContextEntity: Status of the flow.
func flowComplete(
        workflowContext: OstWorkflowContext, 
        ostContextEntity: OstContextEntity
        )
```
```Swift
/// Informs application that flow is interrupted with errorCode.
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
/// Verify data which is scaned from QR-Code
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

For reference you can refer our [ios-demo-app](https://github.com/ostdotcom/ios-demo-app/tree/develop)

There are other references are listed below:

- [OstWorkflowContext](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstWorkflowContext.swift)

- [OstContextEntity](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstContextEntity.swift)

- [OstError](https://github.com/ostdotcom/ost-wallet-sdk-ios/tree/develop/OstWalletSdk/Errors)
