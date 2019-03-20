# ost-Wallet-sdk-iOS

## Introduction

Wallet SDK is a mobile application development SDK that enables developers to integrate the  functionality of a non-custodial crypto-wallet into consumer applications. The functionality
- Safely generate and store keys on their user's  mobile device
- Sign ethereum transactions and data as defined by contracts using EIP-1077
- Enable their user's to recover access to funds in case the user loses their authorized device



## Support

- iOS version : 9.0 and above (**recommended version 10.3** )
- Swift version: 4.2

## Setup

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

## OstSdk APIs


### Initialize the SDK

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

### Setup the device

After initialization, the setupDevice API should be called every time the app launches.
It ensures that the current device is `registered` state before calling OST Platform APIs.<br/><br/>
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

### Activate the user

It authorizes the registered device and activates the user. User activation refers to the deployment of smart-contracts that form the user's Brand Token Wallet.

A user can start engaging with a Brand Token economy once they have been activated.<br/><br/>
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

### Authorize session
A session is a period of time during which a sessionKey is authorized to sign transactions under a pre-set limit on behalf of the user.

The device manager, which controls the tokens authorizes sessions. <br/><br/>
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
A transactions where Brand Tokens are transferred from a user to another actor in the Brand Token economy are signed using `sessionKey` if there is an active session. In the absense of an active session, a new session is authorized.

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

### Get Mnemonic Phrase

The mnemonic phrase represents a human-readable way to authorize a new device. This phrase is 12 words long.
 <br/><br/>
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

A user that has stored their mnemonic phrase can enter it into an appropriate user interface on a new mobile device and authorize that device to be able to control their Brand Tokens.<br/><br/>
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

### Get QR Code To Add Device

A developer can use this method to generate a QR code that displays the information pertinent to the mobile device it is generated on.Scanning this QR code with a authorized mobile device will result in the new device being authorized.<br/><br/>
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
