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
    
    @objc enum OstContnetWorkflowType: Int {
        case activateUser,
        updateBiometricPreference
        
        func getWorkflowName() -> String {
            switch self {
            case .activateUser:
                return "activate_user"
            case .updateBiometricPreference:
                return "biometric_preference"
                
            default:
                return ""
            }
        }
    }
    
    @objc enum OstContentControllerType: Int {
        case createPin,
        confirmPin
        
        func getControllerName() -> String {
            switch self {
            case .createPin:
                return "create_pin"
                
            case .confirmPin:
                return "confirm_pin"
                
            default:
                return ""
            }
        }
    }
    
    @objc enum OstContentComponentType: Int {
        case titleLabel,
        leadLabel,
        infoLabel,
        tcLabel,
        placeholders
        
        func getCompnentName() -> String {
            switch self {
            case .titleLabel:
                return "title_label"
                
            case .leadLabel:
                return "lead_label"
                
            case .infoLabel:
                return "info_label"
                
            case .tcLabel:
                return "terms_and_condition_label"
                
            case .placeholders:
                return "placeholders"
                
            default:
                return ""
            }
        }
    }
    
    /// Initialize
    ///
    /// - Parameter contentConfig: Config
    @objc
    init(contentConfig: [String: Any]? = nil) {
        let data = OstBundle.getContentOf(file: "OstContentConfig", fileExtension: "json")
        var finalConfig = try! OstUtils.toJSONObject(data!) as! [String: Any]
        OstUtils.deepMerge(contentConfig ?? [:], into: &finalConfig)
        
        self.contentConfig = finalConfig
        
        super.init()
        OstContent.instance = self
    }
    
    /// Get workflow config
    ///
    /// - Parameter name: workflow type
    /// - Returns: Config dictionary
    @objc
    func getWorkflowConfig(for type: OstContnetWorkflowType) -> [String: Any] {
        
        let workflowConfig = contentConfig[type.getWorkflowName()] as! [String: Any]
        return workflowConfig
    }
    
    /// Get controller config for provided controller name in workflow
    ///
    /// - Parameters:
    ///   - name: Controller type
    ///   - workflowName: Workflow type
    /// - Returns: Controller config dictionary
    @objc
    func getControllerConfig(for name: OstContentControllerType,
                             inWorkflow type: OstContnetWorkflowType) -> [String: Any] {
        
        let workflowConfig = getWorkflowConfig(for: type)
        let config = workflowConfig[name.getControllerName()]
        return config as! [String: Any]
    }
    
    @objc
    /// Get component data from OstContent provided by user
    ///
    /// - Parameters:
    ///   - component: Component name
    ///   - controller: Controller Type
    ///   - workflow: Workflow Type
    /// - Returns: Component config.
    func getComponentData(component: OstContentComponentType,
                          inController controller: OstContentControllerType,
                          forWorkflow workflow: OstContnetWorkflowType) -> [String: Any]? {
        
        let controllerConfig = getControllerConfig(for: controller, inWorkflow: workflow)
        let component = controllerConfig[component.getCompnentName()]
        return component as? [String: Any]
    }
}
