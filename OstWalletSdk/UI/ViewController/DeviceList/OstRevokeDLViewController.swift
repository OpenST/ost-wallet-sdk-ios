/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstRevokeDLViewController: OstDeviceListViewController {
    public class func newInstance(userId: String,
                                  callBack: @escaping (([String: Any]?) -> Void)) -> OstRevokeDLViewController {
        let instance = OstRevokeDLViewController()
        setEssentials(instance: instance,
                      userId: userId,
                      callBack: callBack)
        return instance;
    }
    
    class func setEssentials(instance: OstRevokeDLViewController,
                             userId: String,
                             callBack: @escaping (([String: Any]?) -> Void)) {
        instance.onCellSelected = callBack
        instance.userId = userId
    }
    
    override func configure() {
        pageConfig = OstContent.getRevokeDeviceVCConfig()
        super.configure()
    }
}
