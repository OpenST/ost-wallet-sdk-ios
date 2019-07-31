# OST Wallet UI iOS

## Introduction

Wallet UI SDK is useful to integrate OstWalletSdk in application with availabel UI components.

## Setup

To setup OstWalletUI, please refer [setup]().

## OstWalletUI SDK APIs
To use OstWalletUI `import OstWalletSdk`

### Set Theme Config

Theme for OstWalletUI can be initialized by calling `setThemeConfig` API which setup OstWalletUI theme config

```Swift
OstWalletUI.setThemeConfig(config)
```

### Set Content Config

Content for OstWalletUI can be initialized by calling `setContentConfig` API which  setup OstWalletUI content config

**Parameters**<br/>
&nbsp;_config: Config to use for UI_<br/>

While activating user  `create_pin["terms_and_condition_url"]` url is used to show terms and conditions. While confirming pin `terms_and_condition_url["terms_and_condition_url"]` url is used to open.

```Swift
let config: [String: Any] = [
    "activate_user": [
        "create_pin": [
            "terms_and_condition_url": "https://ost.com/terms"
        ],
        "confirm_pin": [
            "terms_and_condition_url": "https://ost.com/terms"
        ]
    ]
]

OstWalletUI.setContentConfig(config)
```

### Activate User

User activation refers to the deployment of smart-contracts that form the user's Brand Token wallet. An activated user can engage with a Brand Token economy.<br/><br/>
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
) -> String {
```

### Initialize Recovery

A user can control their Brand Tokens using their authorized devices. If they lose their authorized device, they can recover access to their BrandTokens by authorizing a new device via the recovery process .<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_recoverDeviceAddress: Device address which wants to recover_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

If application set `recoverDeviceAddress` then OstWalletUI ask for `pin` to initiate device recovery. Else it displays authorized device list for given `userId` to select device from. 

```Swift
OstWalletUI.initiateDeviceRecovery(
    userId: String,
    recoverDeviceAddress: String? = nil,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String {
```

### Abort Device Recovery

To abort initiated device recovery.<br/><br/>
**Parameters**<br/>
&nbsp;_userId: OST Platform user id provided by application server_<br/>
&nbsp;_passphrasePrefixDelegate: Callback implementation object to get passphrase prefix from application_<br/>

&nbsp;_Returns: Workflow Id(use to subscribe object to listen callbacks from perticular workflow id)_<br/>

```Swift
OstWalletUI.abortDeviceRecovery(
    userId: String,
    passphrasePrefixDelegate: OstPassphrasePrefixDelegate
) -> String {
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
