# OST Wallet SDK Changelog

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

