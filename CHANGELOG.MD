# OST Wallet SDK Changelog

## Version 2.4.1
### Feature
* User can authorize external session by scanning QR-Code.
* User can pass QR-Code payload to perform QR-Code actions without opening Scanner in OstWalletUI. This functionality is available for `scanQRCodeToAuthorizeSession`, `scanQRCodeToExecuteTransaction`, `scanQRCodeToAuthorizeDevice`.   


## Version 2.4.0
### Feature
* `getRedeemableSkus` and `getRedeemableSkuDetails` apis added in `OstJsonApi`.
 

## Version 2.3.6
### Feature
* Theme config getter method added in SDK.
* Notifying custom loader about invalid QR code scanned.
* customization options added in `OstThemeConfig`


## Version 2.3.5
### Feature
* Developer can display application loader for OstWalletUI workflow.

## Version 2.3.4
### Feature:
* Developer can decide whether use existing keys or create new keys for User on application reinstall by setting `EnableIOSDeviceRestore` flag in `OstWalletSdk.plist`.
### Bug Fix:
* Fetching data from database fix.

## Version 2.3.3
### Bug Fix:
* OstWalletSdkUI issue fixed for iOS 13. 


## Version 2.3.2
### Bug Fix:
* Handling of invalid OstWalletSdk config added.
* Error code string for `userCancelled` typo fix.

## Version 2.3.1
### Feature:
* OstWalletUI now supports
    - get add device QR-Code
    - scan QR-Code to authorize device
    - scan QR-Code to execute transaction
    - authorize current device with mnemonics
* Api provided to fetch current device from OstPlatform.
* Now supports getting active sessions from Sdk.

## Version 2.3.0
### Feature:
* OstWalletSdk now contains UI.
* UI components can be modified.
* Languages for UI workflow components can be modified.
* OstWalletUI now supports
    - activate user
    - create session
    - get device mnemonics
    - revoke device
    - reset pin
    - initiate device recovery
    - abort device recovery
    - update biometric preference

## Version 2.2.3
### Bug Fix:
* Inconsistent signature generation fix.

## Version 2.2.2
### Bug Fix:
* Scanning unrecognized QR codes no longer causes the SDK to crash

## Version 2.2.1
### Bug Fix:
* Fix `fetchDevice` cache issue for `initiateDeviceRecovery`
### Security Enhancements
* Implemented public-key pinning for api.ost.com 


## Version 2.2.0
### Changes: 
* Added Multi Currency Feature which allows developers to specify fiat-currency at runtime while executing a transaction.
* Added OstJsonApi that allows developers to fetch data from Ost Platform. Please see README.MD for supported Api(s).

## Version 2.1.0
### Changes: 
* Biometric preferences are now saved in the SDK
* Remove hard-coding of OST as the value token that backs Brand Tokens 
* Now supports device access revocation via API
* Now supports Objective-C

## Version 2.0.4
### Changes: 
* Removed integer support for solidity SHA-3 to enable SDK compilation with Xcode 10.2.1

## Version 2.0.3
### Changes: 
* Fixed a bug that blocked PIN Reset during recovery.The PIN Reset now works during recovery

## Version 2.0.2

### Changes:
* Added Dependencies to the Readme
* Updated the recommended configurations

## Version 2.0.1

### Changes:
* Added CHANGELOG.md
* Updated cartfile with CryptoSwift version that is compatible with swift-4
* Added Cartfile.resolved to ensure that sdk setup doesn't break
* Using a deterministic password along with Mnemonics to generate keys.Using a deterministic password not only increases security, but also ensures that no two users can accidentally generate the same key
* `UseSeedPassword` configuration added to support backwards compatibility with v2.0.0

