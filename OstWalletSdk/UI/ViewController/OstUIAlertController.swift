/**
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
**/

import UIKit

class OstUIAlertController: UIAlertController {
    var parentWindow:UIWindow? = nil;
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.statusBar-1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
        self.parentWindow = win;
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            if ( nil != completion ) {
                completion!();
            }
            self.parentWindow = nil;
            print("OstWalletUI :: OstUIAlertControllerViewController :: self.parentWindow has been released!");
        }
    }
}
