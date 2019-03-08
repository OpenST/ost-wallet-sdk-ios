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

iOS version : 9.0 and above (**suggested version 10.3** )

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
    delegate: OstWorkFlowCallbackProtocol
    )
```    
     
### Activate User

It Authorizes the Registered device and Activate the user.
It makes user eligible to do device operations and transactions.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_pin: User Pin_<br/>
&nbsp;_password: Password provided by application server_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfter: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.activateUser(
    userId: String,
    pin: String,
    password: String,
    spendingLimit: String,
    expireAfter: TimeInterval,
    delegate: OstWorkFlowCallbackProtocol
    )
```
                     
### Add Session

To add new session to device manager.
Will be used when there are no current session available to do transactions.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in WEI_<br/>
&nbsp;_expireAfter: Session key validat duration_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.addSession(
    userId: String,
    spendingLimit: String,
    expireAfter: TimeInterval,
    delegate: OstWorkFlowCallbackProtocol
    )
```

### Execute Transaction

To execute Rule.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_transactionType: ExecuteTransactionType value_<br/>
&nbsp;_toAddresses: Token holder addresses of amount receiver_<br/>
&nbsp;_amounts: Amounts corresponding to tokenHolderAddresses in wei to be transfered_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.executeTransaction(
    userId: String,
    tokenId: String,
    transactionType: ExecuteTransactionType,
    toAddresses: [String],
    amounts: [String],
    delegate: OstWorkFlowCallbackProtocol
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
    delegate: OstWorkFlowCallbackProtocol
    )
```

### Add Device Using Mnemonics

It add new device using mnemonics provided.
Using mnemonics it generates wallet key to add new current device.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_mnemonics: String value of mnemonics_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.addDeviceWithMnemonicsString(
    userId: String,
    mnemonics: String,
    delegate: OstWorkFlowCallbackProtocol
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
    delegate: OstWorkFlowCallbackProtocol
    )
```

### Reset Pin

To update current Pin with new Pin.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_password: Password provided by application server_<br/>
&nbsp;_oldPin: Users old Pin_<br/>
&nbsp;_newPin: Users new Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>

```Swift
OstSdk.resetPin(
    userId: String,
    password: String,
    oldPin: String,
    newPin: String,
    delegate: OstWorkFlowCallbackProtocol
    )
```

### Recover Device Initialize

To recover authorized device which could be misplaced or no more in use.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OstKit user id provided by application server_<br/>
&nbsp;_recoverDeviceAddress: Device address which wants to recover_<br/>
&nbsp;_password: Password provided by application server_<br/>
&nbsp;_uPin: Users Pin_<br/>
&nbsp;_delegate: Callback implementation object for application communication_<br/>


```Swift
OstSdk.recoverDeviceInitialize(
    userId: String,
    recoverDeviceAddress: String,
    uPin: String,
    password: String,
    delegate: OstWorkFlowCallbackProtocol
    )
```


## Workflow Callbacks

```Swift
/// Register device passed as parameter.
///
/// - Parameters:
///   - apiParams: Register Device API parameters.
///   - ostDeviceRegisteredProtocol: To pass response.
func registerDevice(_ apiParams: [String: Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol)
```
```Swift
/// Pin needed to check the authenticity of the user.
/// Developers should show pin dialog on this callback.
///
/// - Parameters:
///   - userId: Id of user whose password and pin are needed.
///   - ostPinAcceptProtocol: To pass pin
func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol)
```
```Swift    
/// Inform SDK user about invalid pin.
/// Developers should show invalid pin error and ask for pin again on this callback.
///
/// - Parameters:
///   - userId: Id of user whose password and pin are needed.
///   - ostPinAcceptProtocol: To pass another pin.
func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol)
```
```Swift
/// Inform SDK user that entered pin is validated.
/// Developers should dismiss pin dialog on this callback.
/// - Parameter userId: Id of user whose pin and password has been validated.
func pinValidated(_ userId: String)
```
```Swift
/// Inform SDK user the the flow is complete.
///
/// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
/// - Parameter ostContextEntity: Status of the flow.
func flowComplete1(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity)
```
```Swift
/// Inform SDK user that flow is interrupted with errorCode.
/// Developers should dismiss pin dialog (if open) on this callback.
///
/// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
/// - Parameter ostError: Reason of interruption.
func flowInterrupted1(workflowContext: OstWorkflowContext, error: OstError)
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
func verifyData(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity, delegate: OstValidateDataProtocol)
```
```Swift
/// Acknowledge user about the request which is going to make by SDK.
///
/// - Parameters:
///   - workflowContext: OstWorkflowContext
///   - ostContextEntity: OstContextEntity
func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity)
```



