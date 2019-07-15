/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var introViewController: IntroViewController?
    var tabbarController: TabBarViewController?
    var navigationController: UINavigationController?
    
    private var webPageUrl:AppUrlData? = nil;
    private var hasLink:Bool = false;
    

    func getWebPageUrl() -> AppUrlData? {
        return webPageUrl;
    }
    func clearWebPageUrl() {
        webPageUrl = nil;
        hasLink = false;
    }
    
    func hasWebLink() -> Bool {
        return hasLink;
    }
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true;
    }
    
    var temp:[UIApplication.LaunchOptionsKey: Any]? = nil;
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        showIntroController(fetchUser: true)
        IQKeyboardManager.shared.enable = true
        temp = launchOptions;
        if ((launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary]) != nil) {
            
            let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] ?? [AnyHashable: Any]()
            if ( nil != activityDictionary["UIApplicationLaunchOptionsUserActivityKey"] ) {
                let activityType = activityDictionary["UIApplicationLaunchOptionsUserActivityTypeKey"] as? String;
                if ( nil != activityType && NSUserActivityTypeBrowsingWeb == activityType ) {
                    //Application launched with url.
                    hasLink = true;
                }
            }
            
        }
        return true;
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            
            let urlPath = url.path;
            //1. Ensure path begins with /demo-wallet/
            //2. Ensure action is present.
            if ( !urlPath.hasPrefix( "/ost-wallet/") || url.pathComponents.count < 3 ) {
                return true;
            }
            webPageUrl = AppUrlData(url: url);
            introViewController?.appUrlDataAvailable();
            tabbarController?.appUrlDataAvailable();
        }
        return true;
    }
    
    func showIntroController(fetchUser: Bool = false) {
        introViewController = IntroViewController();
        introViewController?.fetchUser = fetchUser
        navigationController = UINavigationController(rootViewController: introViewController!)
        window?.rootViewController = navigationController!;
        window?.makeKeyAndVisible();
        tabbarController = nil
    }
    
    func showTabbarController(_ workflowCallback: OstWorkflowCallbacks? = nil) {
        tabbarController = TabBarViewController()
        tabbarController!.workflowCallbacks = workflowCallback
        window?.rootViewController = tabbarController!;
        window?.makeKeyAndVisible();
        introViewController = nil
    }
    

    
//    func applicationWillResignActive(_ application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//
//    func applicationWillTerminate(_ application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }
}



