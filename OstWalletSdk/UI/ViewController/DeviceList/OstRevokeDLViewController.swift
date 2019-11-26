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
                                  workflowRef: OstWorkflowCallbacks,
                                  callBack: @escaping (([String: Any]?) -> Void)) -> OstRevokeDLViewController {
        let instance = OstRevokeDLViewController()
        setEssentials(instance: instance,
                      userId: userId,
                      workflowRef: workflowRef,
                      callBack: callBack)
        return instance;
    }
    
    class func setEssentials(instance: OstRevokeDLViewController,
                             userId: String,
                             workflowRef: OstWorkflowCallbacks,
                             callBack: @escaping (([String: Any]?) -> Void)) {
        instance.onCellSelected = callBack
        instance.workflowRef = workflowRef
        instance.userId = userId
    }
    
    override func configure() {
        pageConfig = OstContent.getRevokeDeviceVCConfig()
        super.configure()
    }
    
    override func getWorkflowType() -> OstWorkflowType {
        return .revokeDevice
    }
}
