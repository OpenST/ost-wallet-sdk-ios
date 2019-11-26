# Mock Custom Loader Useage

## Setup
1. Custom Loader code has been written in `Swift` language, after adding into `Objective-C` application, xcode may ask to add `<PRODUCT_NAME>-Bridging-Header.h` .
2. Drag `CustomLoader` folder into application bundle
4. Open `AppDelegate.swift` or `AppDelegate.m` and add loader manager initialization command

<b>Swift:</b>
```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	let mockLoader = OstMockLoaderManager()
	OstWalletUI.setLoaderManager(mockLoader)
}
```
<b>Objective-C:</b>
```Objective-C
#import "<PRODUCT_NAME>-Swift.h"
#import <OstWalletSdk/OstWalletSdk-Swift.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	OstMockLoaderManager *mockLoader = [[OstMockLoaderManager alloc]init];
	[OstWalletUI setLoaderManager: mockLoader];
}
```

After performing above steps, you are good to go with custom loader. 

## Customize Loader

You can customize icons and text for custom loader as per application need.

### 1. Loader gif:
To modfiy loader, get `.gif` file and rename as `OstProgressImage.gif`. After that, replace it with `CustomLoader/OstProgressImage.gif`<br/>

### 2. Success and Failure Icon:
To modify Icons, open `CustomLoader/OstLoaderAssets.xcassets` and replace `OstSuccessAlertIcon` and `OstFailureAlertIcon` with application icons

### 3. Modify success message:
Developer can modify success message by modifying `SUCCESS_MESSAGE` value in `CustomLoader/OstSdkMessages.json` file

### 4. Modify loader text:
To modify loader text, update language for key `text` under `initial_loader`, `loader` and `acknowledge` in ost_content_config. <br/>
ost_content_config is a file, which you set for `setContentConfig` function. 
