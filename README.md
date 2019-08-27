# OST Wallet SDK iOS

## Introduction

Wallet SDK is a mobile application development SDK that enables developers to integrate the functionality of a non-custodial crypto-wallet into consumer applications. The SDK:

- Safely generates and stores keys on the user's mobile device
- Signs data as defined by contracts using EIP-1077 and EIP-712
- Enables users to recover access to their Brand Tokens in case the user loses their authorized device</br>

Starting version `2.3.0` the SDK also provides built-in User Interface Components which are themeable and support content customization. Please refer [OstWalletUI](./documentation/OstWalletUI.md)

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


### A). Installing iOS Wallet SDK using [Carthage](https://github.com/Carthage/Carthage)

#### i). Installing [Carthage](https://github.com/Carthage/Carthage)

Get [Carthage](https://github.com/Carthage/Carthage) by running the following command on terminal

```bash
brew install carthage
```

You can also choose [other methods](https://github.com/Carthage/Carthage/#installing-carthage) to install [Carthage](https://github.com/Carthage/Carthage)

<br>

#### ii). Installing wallet SDK using Carthage
Carthage looks at a file called `Cartfile` to determine which libraries to install. Create a file in the same directory as your Xcode project called `Cartfile` and enter the following to tell Carthage which dependencies we want:

Add following entry in your `Cartfile`

```bash
github "ostdotcom/ost-wallet-sdk-ios"  == 2.3.0

```

Now to actually install everything run the following in your terminal:

```bash
carthage update --platform iOS

```

A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is.


<br>

#### iii). Copying the `OstWalletSdk.framework` file in your Xcode project



Open your project in Xcode, click on the project file in the left section of the screen and scroll down to the `Linked Frameworks and Libraries` section in Xcode.

`Carthage` folder will have the `.framework` files that we will add in Xcode project.

Now open the `Carthage/Build/iOS` folder in Finder:

Run this command

```bash
open Carthage/Build/iOS
```

Open application target, under General tab, drag the built `OstWalletSdk.framework` binary from `Carthage/Build/iOS` folder into Linked Frameworks and Libraries section.

![copy-framework-file](https://dev.ost.com/platform/docs/sdk/assets/copy-framework-file.png)

#### iv). Adding the `OstWalletSdk` dependencies in your Xcode project
We need to add the `.framework` files of dependencies present inside `Carthage/Build/iOS`.

Open `application targets` in Xcode. Under `Build Phases` click `+` icon and choose `New Run Script Phase`. Add the following command.

```bash
/usr/local/bin/carthage copy-frameworks
```

Click the `+` under `Input Files` and add the following framework entires:

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


<br>

![copy-framework-file](https://dev.ost.com/platform/docs/sdk/assets/add-dependency-framework-files.png)



#### v). Adding SDK configuration file

Create `OstWalletSdk.plist` file. This file has configuration attributes used by OstWalletSdk. You should copy paste the configuration values from below snippet.


Copy paste this configuration file.

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
    <key>UseSeedPassword</key>
	<false/>
 </dict>
 </plist>
```

1. BlockGenerationTime: The time in seconds it takes to mine a block on auxiliary chain.
2. PricePointTokenSymbol: This is the symbol of base currency. So its value will be `OST`.
3. PricePointCurrencySymbol: It is the symbol of quote currency used in price conversion.
4. RequestTimeoutDuration: Request timeout in seconds for https calls made by ostWalletSdk.
5. PinMaxRetryCount: Maximum retry count to get the wallet Pin from user.
6. SessionBufferTime: Buffer expiration time for session keys in seconds. Default value is 3600 seconds.
7. UseSeedPassword: The seed password is salt to PBKDF2 used to generate seed from the mnemonic. When `UseSeedPassword` set to true, different deterministic salts are used for different keys.

**These configurations are MANDATORY for successful operation. Failing to set them will significantly impact usage.**

#### vi). Add `NSFaceIDUsageDescription` description in `info.plist`

The iOS Wallet SDK can use FaceID in lieu of fingerprint if the hardware supports it. To support faceID, please include  [NSFaceIDUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsfaceidusagedescription) key in your application's `info.plist` file and describe its usage.

**Note: [NSFaceIDUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsfaceidusagedescription) key is supported in iOS 11 and later.**


#### vii). Initialize the Wallet SDK
SDK initialization should happen before calling any other `workflow`. To initialize the SDK, we need to call `init` workflow of Wallet SDK. It initializes all the required instances and run db migrations.

Recommended location to call **OstWalletSdk.initialize()** is in [application](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application) method of [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate).

```swift
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try OstWalletSdk.init(apiEndPoint: <OST_PLATFORM_API_ENDPOINT>)
     } catch let ostError {
           // Handle error here
     }
     return true
}
```


```
OstWalletSdk.initialize(apiEndPoint: String)
```

| Parameter | Description |
|---|---|
| **apiEndPoint** <br> **String**	| OST PLATFORM API ENDPOINT: <br> 1. Sandbox Environment: `https://api.ost.com/testnet/v2/` <br> 2. Production Environment: `https://api.ost.com/mainnet/v2/` |


## OST Wallet SDK APIs

### Types of Methods

1. `Workflows`: Workflows are the core functions provided by wallet SDK to do wallet related actions. Workflows can be called directly by importing the SDK.

	* Callbacks must confirm to `OstWorkflowDelegate` protocol. The `OstWorkflowDelegate` protocol defines methods that allow application to interact with `OstWalletSdk`.


2. `Getters`: These functions are synchronous and will return the value when requested.

3. `JSON APIs`: Methods that allows application to access OST Platform APIs. 



## Workflows

### 1. setupDevice
This workflow needs `userId` and `tokenId` so `setupDevice` should be called when the application has determined that the user is logged in state. Using the mapping between userId in OST Platform and your app user, you have access to `userId` and `tokenId`.

**If the user is logged in, then `setupDevice` should be called every time the app launches, this ensures that the current device is registered before communicating with OST Platform server.**


```
OstWalletSdk.setupDevice(
    userId: String,
    tokenId: String,
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform  |
| **tokenId** <br> **String**	| Unique identifier of the token economy |
| **delegate** <br> **OstWorkflowDelegate**	|An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).<br> This object should implement `registerDevice` callback function. `registerDevice` will be called during the execution of this workflow.  |

<br>

### 2. activateUser
It `authorizes` the registered device and activates the user. User activation deploys  **TokenHolder**, Device manager  contracts on blockchain. Session keys are also created and authorized during `activateUser` workflow. So after `user activation`, users can perform wallet actions like executing transactions and reset pin. `activateUser` needs to be executed once for a user in an economy.

```
OstWalletSdk.activateUser(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    spendingLimit: String,
    expireAfterInSecs: TimeInterval,
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform  |
| **userPin** <br> **String**	| User's PIN created during wallet setup.|
| **passphrasePrefix** <br> **String**	| A constant unique identifier for your user. |
| **spendingLimit** <br> **String**	| Spending limit of session key in [atto BT](https://dev.ost.com/platform/docs/guides/execute-transactions/).  |
| **expireAfterInSec** <br> **TimeInterval**	| Expire time of session key in seconds. |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |



<br>

### 3. addSession
This workflow will create and authorize the session key that is needed to do the transactions. This flow should be called if the session key is expired or not present. 

```
OstWalletSdk.addSession(
    userId: String,
    spendingLimit: String,
    expireAfterInSecs: TimeInterval,
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	|  Unique identifier of the user stored in OST Platform|
| **spendingLimit** <br> **String**	| Spending limit of session key in [atto BT](https://dev.ost.com/platform/docs/guides/execute-transactions/).   |
| **expireAfterInSecs** <br> **long**	| Expire time of session key in seconds.  |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol). |





<br>

### 4. perfromQRAction
This workflow will perform operations after reading data from a QRCode. This workflow can be used to add a new device and to do the transactions.

```
OstWalletSdk.perfromQRAction(
    userId: String,
    payload: String,
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform|
| **data** <br> **String**	| JSON object string scanned from QR code. <br> [Sample QRCode JSON](https://dev.ost.com/platform/docs/guides/execute-transactions/#generating-qrcode-with-transaction-data) |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol). |



<br>

### 5. getDeviceMnemonics
To get the 12 words recovery phrase of the current device key. Users will use it to prove that it is their wallet.  

```
OstWalletSdk.getDeviceMnemonics(
    userId: String,
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol). |



<br>

### 6. executeTransaction
Workflow should be used when user wants to transfer tokens.

```
OstWalletSdk.executeTransaction(
    userId: String,
    tokenHolderAddresses: [String],
    amounts: [String],
    transactionType: OstExecuteTransactionType,
    meta: [String: String],
    options: [String: Any],
    delegate: OstWorkflowDelegate
)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform|
| **tokenHolderAddresses** <br> **[String]**	|  **TokenHolder**  addresses of beneficiary users.  |
| **amounts** <br> **[String]**	| Array of Amount to be transferred in atto.  |
| **transactionType** <br> **OstExecuteTransactionType**	| Transaction type can take one of the two values: <br> 1. `DirectTransfer`:  In this type of transaction, the amount of brand token will be transferred directly to the receiver user. <br> 2. `Pay`: In this type of transaction the amount of fiat passed will first be converted into brand token and after this conversion the transfer will happen in converted brand token amount.|
| **meta** <br> **[String: String]**	| Dictionary object having extra information that a developer can pass about the transfer. This dictionary object can have 3 properties. <br><br>Example meta:  <br>[<br>&nbsp; &nbsp;"name":"Thanks for like", <br>&nbsp; &nbsp;"type": "user_to_user" (it can take one of the following values: `user_to_user`, `user_to_company` and `company_to_user`), <br>&nbsp; &nbsp;  "details": "like"<br>] |
| **options** <br> **[String: Any]**	| Optional settings parameters. You can set following values: <br> 1. `currency_code`: Currency code for the pay currency. <br> Example: `{"currency_code": "USD"}`|
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol). |




<br>

### 7. authorizeCurrentDeviceWithMnemonics
This workflow should be used to add a new device using 12 words recovery phrase. 

```
OstWalletSdk.authorizeCurrentDeviceWithMnemonics(
    userId: String,
    mnemonics: [String],
    delegate: OstWorkflowDelegate
)

```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform|
| **mnemonics** <br> **[String]**	| Array of String having 12 words |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |




<br>   

### 8. resetPin
This workflow can be used to change the PIN.

**User will have to provide the current PIN in order to change it.**

```
OstWalletSdk.resetPin(
    userId: String,
    passPhrasePrefix: String,
    oldUserPin: String,
    newUserPin: String,
    delegate: OstWorkflowDelegate
)
```


| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
| **passPhrasePrefix** <br> **String**	| A constant unique identifier for a your user. |
| **oldUserPin** <br> **String**	| Current wallet PIN  |
| **newUserPin** <br> **String**	| New wallet PIN |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |



### 9. initiateDeviceRecovery
A user can control their Brand Tokens using their authorized devices. If they lose their authorized device, they can recover access to their Brand Tokens by authorizing a new device by initiating the recovery process.

```swift
OstWalletSdk.initiateDeviceRecovery(
    userId: String,
    recoverDeviceAddress: String,
    userPin: String,
    passphrasePrefix: String,
    delegate: OstWorkflowDelegate
    )
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
| **recoverDeviceAddress** <br> **String**	| Unique identifier for the user of economy |
| **userPin** <br> **String**	| User's Wallet PIN  |
| **passPhrasePrefix** <br> **String**	| A constant unique identifier for a your user. |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |




### 10. abortDeviceRecovery
This workflow can be used to abort the initiated device recovery.

```swift
OstWalletSdk.abortDeviceRecovery(
    userId: String,
    userPin: String,
    passphrasePrefix: String,
    delegate: OstWorkflowDelegate)
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
| **userPin** <br> **String**	| User's Wallet PIN  |
| **passPhrasePrefix** <br> **String**	| A constant unique identifier for a your user. |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |



### 11. logoutAllSessions
This workflow will revoke all the sessions associated with the provided userId.

```swift
OstWalletSdk.logoutAllSessions(
    userId: String,
    delegate: OstWorkflowDelegate)
```


| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |




### 12. revokeDevice

To revoke device access.

```Swift
OstWalletSdk.revokeDevice(
    userId: String,
    deviceAddressToRevoke: String,
    delegate: OstWorkflowDelegate) 
```


| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
|	**deviceAddressToRevoke** <br> **String**| Wallet address of the device to revoke. |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |




### 13. updateBiometricPreference

This method can be used to enable or disable the biometric.

```Swift
OstWalletSdk.updateBiometricPreference(
    userId: String,
    enable: Bool,
    delegate: OstWorkflowDelegate) 
```


| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier for the user of economy |
| **enable** <br> **Bool**| Preference to use the biometric. |
| **delegate** <br> **OstWorkflowDelegate**	| An instance of a class that implements the callback function available in `OstWorkflowDelegate` protocol. These callback functions are needed for communication between app and wallet SDK. Implement `flowComplete` and `flowInterrupt` callback functions to get the workflow status. Details about other callback function can be found in [OstWorkflowDelegate protocol reference](#ostworkflowdelegate-protocol).  |




## Getters


### 1. getAddDeviceQRCode
This workflow will return the QRCode in the form of [CIImage object](https://developer.apple.com/documentation/coreimage/ciimage) that can be used to show on screen. This QRCode can then be scanned to add the new device.

```Swift
OstWalletSdk.getAddDeviceQRCode(
    userId: String
) throws -> CIImage?
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform |


**Returns**

| Type | Description |
|---|---|
| **CIImage**	| QRCode [CIImage](https://developer.apple.com/documentation/coreimage/ciimage) object. |




### 2. getUser
Get user entity for given userId.

```Swift
OstWalletSdk.getUser(userId: String) 
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform |


**Returns**

| Type | Description |
|---|---|
| **User**	| The user object |



### 3. getToken 
Get token entity for given tokenId.

```Swift
OstWalletSdk.getToken(tokenId: String) 
```

| Parameter | Description |
|---|---|
| **tokenId** <br> **String**	| Unique identifier of the token |

**Returns**


| Type      | Description      |
|-----------|------------------|
| **Token**	| The token object |


### 4. user.getCurrentDevice
Get current device of user.

```Swift
let user: OstUser = OstWalletSdk.getUser(userId: String)
let device: OstCurrentDevice = user.getCurrentDevice()
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user stored in OST Platform |


**Returns**

| Type        | Description       |
|-------------|-------------------|
| **device**	| The device object |

### 5. isBiometricEnabled
Get biometric preference of the user.

```Swift
OstWalletSdk.isBiometricEnabled(userId: String) 
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**    | Unique identifier of the user stored in OST Platform |


**Returns**

| Type                            | Description |
|---------------------------------|---------------------------------------------------|
| **Preference** <br> **Bool**      | `true` if user has enabled biometric verfication. |


### 6. getActiveSessions
Get active sessions for given spending limit.
If  passed spending limit is nil, return all active sessions.
```Swift
OstWalletSdk.getActiveSessions(
    userId: String, 
    spendingLimit: String?
) -> [OstSession]
```

| Parameter | Description |
|---|---|
| **userId** <br> **String**    | Unique identifier of the user stored in OST Platform |
| **spendingLimit** <br> **String**    | Transction amount |


**Returns**

| Type                            | Description |
|---------------------------------|---------------------------------------------------|
| **OstSession** <br> **Array**      | List of active sessions |


## OstWorkflowDelegate Protocol


### 1. flowComplete

This function will be called by wallet SDK when a workflow is completed. The details of workflow and the entity that was updated during the workflow will be available in arguments.

```
func flowComplete(
        workflowContext: OstWorkflowContext, 
        ostContextEntity: OstContextEntity
        )
```

| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	|	Information about the workflow	|
| **ostContextEntity** <br> **OstContextEntity**	| Information about the entity |



<br>




### 2. flowInterrupt
This function will be called by wallet SDK when a workflow fails or cancelled. The workflow details and error details will be available in arguments.

```
func flowInterrupted(
        workflowContext: OstWorkflowContext, 
        error: OstError
)
```

| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	| Information about the workflow |
| **ostError** <br> **OstError**	| ostError object will have details about the error that interrupted the flow |




<br>




### 3. requestAcknowledged
This function will be called by wallet SDK when the core API request was successful which happens during the execution of workflows. At this stage the workflow is not completed but it shows that the main communication between the wallet SDK and OST Platform server is complete. <br>Once the workflow is complete, the `app` will receive the details in `flowComplete` function and if the workflow fails then app will receive the details in `flowInterrupt` function. 

```
func requestAcknowledged(
        workflowContext: OstWorkflowContext, 
        ostContextEntity: OstContextEntity
        )
```

| Argument | Description |
|---|---|
| **ostWorkflowContext** <br> **OstWorkflowContext**	| Information about the workflow	|
| **ostContextEntity** <br> **OstContextEntity**	| Information about the entity |

<br>


### 4. getPin
This function will be called by wallet SDK when it needs to get the PIN from the `app` user to authenticate any authorized action.
<br>**Expected Function Definition:** Developers of client company are expected to launch their UI to get the PIN from the user and pass back this PIN to SDK by calling **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** 

```
func getPin(
        _ userId: String, 
        delegate: OstPinAcceptDelegate
        )
```

| Argument | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user |
| **delegate** <br> **OstPinAcceptDelegate**	| **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** should be called to pass the PIN back to SDK. <br> For some reason if the developer wants to cancel the current workflow they can do it by calling **delegate.cancelFlow()**|




<br>




### 5. pinValidated
This function will be called by wallet SDK when the PIN is validated. 

```
func pinValidated(_ userId: String)
```

| Argument | Description |
|---|---|
| **userId** <br> **String**	| Unique identifier of the user |



<br>



### 6. invalidPin
This function will be called by wallet SDK when the entered PIN was wrong and `app` user has to provide the PIN again. Developers are expected to get the PIN from user again and pass back the PIN back to the SDK by calling  **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** .

```
func invalidPin(
        _ userId: String, 
        delegate: OstPinAcceptDelegate
        )
```

| Argument | Description |
|---|---|
| **userId** <br> **String**	|	Unique identifier of the user	|
| **delegate** <br> **OstPinAcceptDelegate**	| **delegate.pinEntered(_ userPin: String, passphrasePrefix: String)** should be called to again pass the PIN back to SDK. <br> For some reason if the developer wants to cancel the current workflow they can do it by calling **delegate.cancelFlow()** |


<br>


### 7. registerDevice
This function will be called by wallet SDK to register the device.<br>**Expected Function Definition:** Developers of client company are expected to register the device by communicating with their company's server. On client company's server they can use `Server SDK` to register this device in OST Platform. Once device is registered on OST client company's server will receive the newly created `device` entity. This device entity should be passed back to the `app`.<br>
Finally they should pass back this newly created device entity back to the wallet SDK by calling **delegate.deviceRegistered(_ apiResponse: [String: Any])**.

```
func registerDevice(
        _ apiParams: [String: Any], 
        delegate: OstDeviceRegisteredDelegate
        )
```

| Argument | Description |
|---|---|
| **apiParams** <br> **[String: Any]**	|	Device information for registration	|
| **delegate** <br> **OstDeviceRegisteredDelegate**	| **delegate.deviceRegistered(_ apiResponse: [String: Any] )** should be called to pass the newly created device entity back to SDK. <br>In case data if there is some issue while registering the device then the current workflow should be canceled  by calling **delegate.cancelFlow()** |



<br>

### 8. verifyData
This function will be called by wallet SDK to verify the data during `performQRAction` workflow.


```
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


## OST JSON APIs
While the getter methods provide application with data stored in device's database, the JSON API methods make API calls to OST Platform servers. Please refer [OstJsonApi](/documentation/OstJsonApi.md) for documentation.

## Classes

1. OstApiError
2. OstError
3. OstContextEntity

### 1. OstApiError
This class is used to provide API related error details in [flowInterrupt](#2-flowinterrupt) callback function. 


You can call following methods on the object of this class to get more details about the error.

#### A). Methods

1. `public func getApiErrorCode() -> String?`
2. `public func getApiErrorMessage() -> String?`
3. `public func getApiInternalId() -> String?`
4. `public func isBadRequest() -> Bool`
5. `public func isDeviceTimeOutOfSync() -> Bool`
6. `public func isApiSignerUnauthorized() -> Bool`


### 2. OstError
This class is used to provide error details in [flowInterrupt](#2-flowinterrupt) callback function. 

You can read following properties on the object of this class to get more details about the error.

#### A). Properties

1. public internal(set) var isApiError = false
2. public let internalCode:String
3. public let errorMessage:String
4. public let messageTextCode:OstErrorText;
5. public var errorInfo: [String: Any]? = nil

<br>

### 3. OstContextEntity
 
This class provides context about the `entity` that is being changed during a [workflow](#workflows). Callback functions that needs to know about the `entity` will receive an object of this class as an argument. 



`entityType` property will return one of the values from this enum.

```swift
public enum OstEntityType {
    case device,
    user,
    array,
    session,
    transaction,
    recoveryOwner,
    string,
    dictionary,
    tokenHolder
}
```

You can read the following properties to get more details about the entity.

### i) Properties

```swift
public private(set) var entity: Any?
public private(set) var entityType: OstEntityType
```

<br>



## OstWorkflowContext
This class provides context about the current [workflow](#workflows). Callback function that needs to know about the current [workflow](#workflows) will get the object of this class as an argument.


`workflowType` property will take one of the values from this enum.

```swift
public enum OstWorkflowType {
    case setupDevice,
    activateUser,
    addSession,
    getDeviceMnemonics,
    performQRAction,
    executeTransaction,
    authorizeDeviceWithQRCode,
    authorizeDeviceWithMnemonics,
    initiateDeviceRecovery,
    abortDeviceRecovery,
    revokeDeviceWithQRCode,
    resetPin,
    logoutAllSessions
}
```

You can read the following properties to get more details about the current [workflow](#workflows).

### i) Properties


#### a) workflowType

```swift
public let workflowType: OstWorkflowType
```

## Demo App

For a sample implementation, please see the [Demo App](demo-app)

