//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstContent: NSObject {
    private static var instance: OstContent? = nil
    @objc
    var contentConfig: [String: Any] = [:]
    
    /// Get Instance for OstContent class
    ///
    /// - Returns: OstContent
    @objc
    class func getInstance() -> OstContent {
        var instance = OstContent.instance
        if nil == instance {
            instance = OstContent(contentConfig: [:])
        }
        return instance!
    }
    
    @objc enum WorkflowType: Int {
        case activateUser
        
        func getWorkflowName() -> String {
            switch self {
            case .activateUser:
                return "activate_user"
            }
        }
    }
    
    /// Initialize
    ///
    /// - Parameter contentConfig: Config
    @objc
    init(contentConfig: [String: Any]) {
        self.contentConfig = contentConfig
        super.init()
        OstContent.instance = self
    }
    
    /// Get workflow config
    ///
    /// - Parameter name: workflow name
    /// - Returns: Config dictionary
    @objc
    func getWorkflowConfig(for type: WorkflowType) -> [String: Any] {
        var config: [String: Any]? = nil
        if let workflowConfig = contentConfig[type.getWorkflowName()] as? [String: Any] {
            config = workflowConfig
        }
        
        if nil == config {
            config = (OstDefaultContent.content[type.getWorkflowName()] as! [String : Any])
        }
        return config!
    }
    

    /// Get controller config for provided controller name in workflow
    ///
    /// - Parameters:
    ///   - name: Controller name
    ///   - workflowName: Workflow name
    /// - Returns: Controller config dictionary
    @objc
    func getControllerConfig(for name: String, inWorkflow type: WorkflowType) -> [String: Any] {
        let workflowConfig = getWorkflowConfig(for: type)
        
        var controllerConfig: [String: Any]? = nil
        if let config = workflowConfig[name] {
            controllerConfig = (config as! [String : Any])
        }
        
        if nil == controllerConfig {
            controllerConfig = ((OstDefaultContent.content[type.getWorkflowName()] as! [String : Any])[name] as! [String : Any])
        }
        
        return controllerConfig!
    }
}

@objc class OstDefaultContent: NSObject {
    static let content: [String: Any] = [
        "activate_user": [
            "create_pin": [
                "terms_and_condition_url": "https://ost.com/terms"
            ],
            "confirm_pin": [
                "terms_and_condition_url": "https://ost.com/terms"
            ]
        ]
    ]
}
