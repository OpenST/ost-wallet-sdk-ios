# OST Wallet SDK Changelog

## Version 2.0.4
### Changes: 
* Removed integer support for solidity SHA-3 to enable SDK compilation with Xcode 10.2.1.

## Version 2.0.3
### Changes: 
* Fixed a bug that blocked PIN Reset during recovery.The PIN Reset now works during recovery.

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

