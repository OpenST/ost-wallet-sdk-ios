/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


class OstPresenterHelper: NSObject {
  var windowObj: UIWindow? = nil
  var vc: OstWorkflowLoader? = nil
  
  func present(loader: OstWorkflowLoader) {
      let win = UIWindow(frame: UIScreen.main.bounds)
      let vc = UIViewController()
      vc.view.backgroundColor = .clear
      win.rootViewController = vc
      win.windowLevel = UIWindow.Level.statusBar-1
      win.makeKeyAndVisible()
      vc.present(loader, animated: true, completion: nil)
      self.windowObj = win;
    self.vc = loader
  }
  
  deinit {
    Logger.log(message: "OstPresenterHelper: deinit", parameterToPrint: nil);
  }
  
  func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    vc?.dismiss(animated: flag) {
          if ( nil != completion ) {
              completion!();
          }
          self.windowObj = nil;
          self.vc = nil
          print("OstWalletUI :: OstUIAlertControllerViewController :: self.parentWindow has been released!");
      }
  }
}
