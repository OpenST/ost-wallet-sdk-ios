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
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            do {
                try OstSdk.initialize(apiEndPoint: <KIT_API_ENDPOINT>)
            } catch let ostError {
            
            }
            return true
        }
    
