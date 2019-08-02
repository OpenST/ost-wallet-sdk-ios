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
            instance = OstContent()
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
    init(contentConfig: [String: Any]? = nil) {
        var finalConfig = OstDefaultContent.content
        OstUtils.deepMerge(contentConfig ?? [:], into: &finalConfig)
        
        self.contentConfig = finalConfig
        
        super.init()
        OstContent.instance = self
    }
    
    /// Get workflow config
    ///
    /// - Parameter name: workflow name
    /// - Returns: Config dictionary
    @objc
    func getWorkflowConfig(for type: WorkflowType) -> [String: Any] {
        let workflowConfig = contentConfig[type.getWorkflowName()] as! [String: Any]
        return workflowConfig
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
        let config = workflowConfig[name]
        return config as! [String: Any]
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
