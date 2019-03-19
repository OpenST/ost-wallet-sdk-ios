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
github "ostdotcom/ost-wallet-sdk-ios"
```

- Run `carthage update --platform iOS`
- A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is
- Open application target, under `General` tab, drag the built `OstSdk.framework` binary from `Carthage/Build/iOS` into `Linked Frameworks and Libraries` section.
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
$(SRCROOT)/Carthage/Build/iOS/OstSdk.framework
```

## OstSdk apis

### Init

To get started with the SDK, you must first initialize SDK by calling _initialize()_ api.
It initializes all the required instances and run migrations of db. 
        
```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try OstSdk.initialize(apiEndPoint: <KIT_API_ENDPOINT>)
     } catch let ostError {
           
     }
     return true
}
```
    
### Setup Device

After init, setupDevice api should be called everytime the app launches.
It ensures current device is in registered state before calling kit apis.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_tokenId: Token id provided by appicationn server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>
 
```Swift
OstSdk.setupDevice(
    userId: String,
    tokenId: String,
    delegate: OstWorkFlowCallbackDelegate
    )
```    
     
### Activate User

It Authorizes the Registered device and Activate the user.
It makes user eligible to do device operations and transactions.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_pin: User Pin_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_spendingLimitInWei: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.activateUser(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    spendingLimitInWei: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkFlowCallbackDelegate
    )
```
                     
### Add Session

To add new session to device manager.
Will be used when there are no current session available to do transactions.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_spendingLimitInWei: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.addSession(
    userId: String,
    spendingLimitInWei: String,
    expireAfterInSec: TimeInterval,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Execute Transaction

To execute Rule.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_tokenHolderAddresses: Token holder addresses of amount receiver_<br/>
&nbsp;_amounts: Amounts corresponding to tokenHolderAddresses in wei to be transfered_<br/>
&nbsp;_transactionType: OstExecuteTransactionType value_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.executeTransaction(
    userId: String,
    tokenHolderAddresses: [String],
    amounts: [String],
    transactionType: OstExecuteTransactionType,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Get Paper Wallet

To get Paper wallet( 12 words used to generate wallet) of the current device.
Paper wallet will be used to add new device incase device is lost<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.getPaperWallet(
    userId: String,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Add Device Using Mnemonics

It add new device using mnemonics provided.
Using mnemonics it generates wallet key to add new current device.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_mnemonics: Array of mnemonics_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.addDeviceUsingMnemonics(
    userId: String,
    mnemonics: [String],
    delegate: OstWorkFlowCallbackDelegate
)
```

### Get QR-Code To Add Device

Getter method which return QR-Code CIImage for add device.
Use this methods to generate QR code of current device to be added from authorized device.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>

```Swift
OstSdk.getAddDeviceQRCode(
    userId: String
    ) throws -> CIImage?
```

### OstPerform

To perform operations based on QR data provided.
Through QR, Add device and transaction operations can be performed.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_payload: Json string of payload is scanned by QR-Code._<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.perfrom(
    userId: String,
    payload: String,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Reset Pin

To update current Pin with new Pin.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_oldUserPin: Users old Pin_<br/>
&nbsp;_newUserPin: Users new Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.resetPin(
    userId: String,
    passphrasePrefix: String,
    oldUserPin: String,
    newUserPin: String,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Recover Device Initialize

To recover authorized device which could be misplaced or no more in use.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_recoverDeviceAddress: Device address which wants to recover_<br/>
&nbsp;_passphrasePrefix: Passphrase prefix provided by application server_<br/>
&nbsp;_userPin: Users Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>


```Swift
OstSdk.recoverDeviceInitialize(
    userId: String,
    recoverDeviceAddress: String,
    userPin: String,
    passphrasePrefix: String,
    delegate: OstWorkFlowCallbackDelegate
    )
```

### Polling

To poll provided entity.
Polling can be used when any entity is in transition status and desired status update is needed.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_entityId: entity id to be polled_<br/>
&nbsp;_entityType: entity type to be polled_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.poll(
    userId: String,
    entityId: String,
    entityType: OstPollingEntityType,
    delegate: OstWorkFlowCallbackDelegate 
    )
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
/// Show paper wallet
///
/// - Parameter mnemonics: array of Words.
func showPaperWallet(mnemonics: [String])
```
```Swift
/// Verify data which is scan from QR-Code
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

For reference you can refer our [Demo-App](https://github.com/ostdotcom/ost-client-ios-sdk/tree/develop/Demo-App/Demo-App)

There are other references are listed below:

- [OstWorkflowContext](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstWorkflowContext.swift)

- [OstContextEntity](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Workflows/OstContext/OstContextEntity.swift)

- [OstError](https://github.com/ostdotcom/ost-client-ios-sdk/blob/develop/OstSdk/Utils/OstError.swift)
