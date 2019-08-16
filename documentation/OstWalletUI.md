# OST Wallet UI iOS

## Introduction
To enable quick integration with SDK, developers can use built-in User Interface Components which are theamable and support content customization.

## Setup

To setup OstWalletUI, please refer [setup](../../README.md#setup).

## OstWalletUI SDK APIs
### Important Notes
1. App must [initialize](../../README.md#initialize-the-sdk) the sdk <em><b>before</b></em> initiating any UI workflows.
2. App must perform [setupDevice](../../README.md#set-up-the-device) workflow <em><b>before</b></em> initiating any UI workflows.


To use OstWalletUI 
```
import OstWalletSdk
```

### Set Theme Config

Theme for OstWalletUI can be initialized by calling `setThemeConfig` API. To define custom theme config, please refer [ThemeConfig](./ThemeConfig.md) documentation.

**Parameters**<br/>
&nbsp;_config: Config to use for UI_<br/>

* Create config file by title `ThemeConfig.json`

```Swift
let bundle  = Bundle.main
gaurd let filepath = bundle.path(forResource: "ThemeConfig", ofType: "json"),
    let content = try? String(contentsOfFile: filepath),
    let contentData = content.data(using: .utf8) else {
        return 
}
let themeConfig = try JSONSerialization.jsonObject(with: contentData, options: [])
```

```Swift
OstWalletUI.setThemeConfig(themeConfig)
```

### Set Content Config

Content for OstWalletUI can be initialized by calling `setContentConfig` API. To define custom content config, please refer [ContentConfig](./ContentConfig.md) documentation. 

**Parameters**<br/>
&nbsp;_config: Config to use for UI_<br/>

* Create config file by title `ContentConfig.json`

```Swift
let bundle  = Bundle.main
gaurd let filepath = bundle.path(forResource: "ContentConfig", ofType: "json"),
    let content = try? String(contentsOfFile: filepath),
    let contentData = content.data(using: .utf8) else {
    return 
}
let contentConfig = try JSONSerialization.jsonObject(with: contentData, options: [])
```
```Swift
OstWalletUI.setContentConfig(contentConfig)
```

### Activate User

User activation refers to the deployment of smart-contracts that form the user's Brand Token wallet. An activated user can engage with a Brand Token economy.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in atto BT_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.activateUser(
    userId: String,
    expireAfterInSec: TimeInterval,
    spendingLimit: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```
### Authorize session

A session is a period of time during which a sessionKey is authorized to sign transactions under a pre-set limit on behalf of the user.

The device manager, which controls the tokens, authorizes sessions.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_expireAfterInSec: Session key validat duration_<br/>
&nbsp;_spendingLimit: Spending limit in a transaction in atto BT_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.addSession(
    userId: String,
    expireAfterInSec: TimeInterval,
    spendingLimit: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

### Get Mnemonic Phrase

The mnemonic phrase represents a human-readable way to authorize a new device. This phrase is 12 words long.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.getDeviceMnemonics(
    userId: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

### Reset a User's PIN

The user's PIN is set when activating the user. This method supports re-setting a PIN and re-creating the recoveryOwner as part of that.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.resetPin(
    userId: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

### Initialize Recovery

A user can control their Brand Tokens using their authorized devices. If they lose their authorized device, they can recover access to their BrandTokens by authorizing a new device via the recovery process. To use built-in device list UI, pass `recoverDeviceAddress` as `nil`.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_recoverDeviceAddress: Device address which wants to recover. When nil is passed, the user is asked to choose a device. _<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

If application set `recoverDeviceAddress` then OstWalletUI ask for `pin` to initiate device recovery. Else it displays authorized device list for given `userId` to select device from. 

```Swift
OstWalletUI.initiateDeviceRecovery(
    userId: String,
    recoverDeviceAddress: String? = nil,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

### Abort Device Recovery

To abort initiated device recovery.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.abortDeviceRecovery(
    userId: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

###  Revoke Device

To revoke device access. To use built-in device list UI, pass `revokeDeviceAddress` as `nil`.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_revokeDeviceAddress: Device address to revoke. When nil is passed, the user is asked to choose a device._<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

If application set `recoverDeviceAddress` then OstWalletUI ask for `pin` to revoke device. Else it displays authorized device list for given `userId` to select device from. 

```Swift
OstWalletUI.revokeDevice(
    userId: String,
    revokeDeviceAddress: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

###  Update Biometric Preference

This method can be used to enable or disable the biometric.

**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_enable: Preference to use biometric_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.updateBiometricPreference(
    userId: String,
    enable: Bool,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String
```

### Subscribe 

Subscribe to specified event of UI Workflow
**Parameters**<br/>
&nbsp;_workflowId: Id of the workflow as returned by methods of OstWalletUI_<br/>
&nbsp;_listner: Callback implementation object to listen events_<br/>

```Swift
OstWalletUI.subscribe(
    workflowId: String,
    listner: OstWorkflowUIDelegate)
```

### Unsubscribe

Unsubscribes the listner from the specified event of UI Workflow.
**Parameters**<br/>
&nbsp;_workflowId: Id of the workflow as returned by methods of OstWalletUI_<br/>
&nbsp;_listner: Callback implementation object to remove from listing events_<br/>

```Swift
OstWalletUI.subscribe(
    workflowId: String,
    listner: OstWorkflowUIDelegate)
```

### View Component Sheet

Component sheet is collection of all components present in OstWalletUI. Developers can verify how components are going to look with provied theme.

```Swift
OstWalletUI.showComponentSheet()
```

## UI Workflow Delegates

### OstPassphrasePrefixDelegate

```Swift
/// Get passphrase prefix from application
///
/// - Parameters:
///   - ostUserId: Ost user id
///   - workflowContext: Workflow context
///   - delegate: Passphrase prefix accept delegate
@objc
func getPassphrase(
    ostUserId:String,
    workflowContext: OstWorkflowContext,
    delegate: OstPassphrasePrefixAcceptDelegate)
    
//To get workflowId call workflowContext.getWorkflowId method.
//To identify the workflow type, use workflowContext.workflowType property.

```

### OstWorkflowUIDelegate


#### requestAcknowledged

```Swift

/// Acknowledge user about the request which is going to make by SDK.
///
/// - Parameters:
///   - workflowContext: A context that describes the workflow for which the callback was triggered.
///   - contextEntity: Context Entity
@objc
func requestAcknowledged(
    workflowContext: OstWorkflowContext,
    contextEntity: OstContextEntity)
    
//To get workflowId call workflowContext.getWorkflowId method.
//To identify the workflow type, use workflowContext.workflowType property.

```

#### flowComplete

```Swift
/// Inform SDK user the the flow is complete.
///
/// - Parameters:
///   - workflowContext: A context that describes the workflow for which the callback was triggered.
///   - contextEntity: Context Entity
@objc
func flowComplete(
    workflowContext: OstWorkflowContext,
    contextEntity: OstContextEntity)

//To get workflowId call workflowContext.getWorkflowId method.
//To identify the workflow type, use workflowContext.workflowType property.

```

#### flowInterrupted

```Swift
/// Inform SDK user that flow is interrupted with errorCode.
///
/// - Parameters:
///   - workflowContext: A context that describes the workflow for which the callback was triggered.
///   - error: Error Entity
@objc
func flowInterrupted(
    workflowContext: OstWorkflowContext,
    error: OstError)
    
//To get workflowId call workflowContext.getWorkflowId method.
//To identify the workflow type, use workflowContext.workflowType property.

```
