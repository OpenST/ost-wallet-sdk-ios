# OST Wallet SDK Change Log.

## Version 2.0.1

### Changes:
* Added CHANGELOG.md
* Updated cartfile with CryptoSwift version that is compatible with swift-4
* Added Cartfile.resolved to ensure that sdk setup doesn't break
* Use a deterministic password along with Mnemonics to generate keys.Using a deterministic password not only increases security, but, also ensures that no two users can accidentally generate the same key.
* `UseSeedPassword` configuration added to support backwards compatibility with v2.0.0

