# OST Wallet SDK Change Log.

## Version 2.0.1

### Note:
From this version onwards, device keys generation mechanism has changed to use a deterministic 
password along with mnemonics. Using a deterministic password, not only increases security, but, 
also ensures that no two users can accidentally generate the same key.

**However**, mnemonics generated using v2.0.0 will not work in this release. If you wish 
to have backwards compatibility please contact support@ost.com and tell us about your use-case.

### Changes:
* Added CHANGELOG.md
* Updated cartfile with CryptoSwift version that is compatible with swift-4
* Added Cartfile.resolved to ensure that sdk setup doesn't break
* Use a deterministic password along with Mnemonics to generate keys.

