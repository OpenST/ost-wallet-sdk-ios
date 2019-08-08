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
    
    @objc enum OstComponentType: Int {
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
    func getWorkflowConfig(for type: String) -> [String: Any] {
        
        let workflowConfig = contentConfig[type] as! [String: Any]
        return workflowConfig
    }
    
    /// Get controller config for provided controller name in workflow
    ///
    /// - Parameters:
    ///   - name: Controller type
    ///   - workflowName: Workflow type
    /// - Returns: Controller config dictionary
    @objc
    func getControllerConfig(for name: String,
                             inWorkflow type: String) -> [String: Any] {
        
        let workflowConfig = getWorkflowConfig(for: type)
        let config = workflowConfig[name]
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
    func getComponentData(component: OstComponentType,
                          inController controller: String,
                          forWorkflow workflow: String) -> [String: Any]? {
        
        let controllerConfig = getControllerConfig(for: controller, inWorkflow: workflow)
        let component = controllerConfig[component.getCompnentName()]
        return component as? [String: Any]
    }
}

extension OstContent {
    typealias OstPinVCComponentData = (titleLabel: [String: Any]?,
        leadLabel: [String: Any]?,
        infoLabel: [String: Any]?,
        tcLabel: [String: Any]?,
        placeholders: [String: Any]?)
    
    class func getComponentData(inController controllerType: String,
                                forWorkflow workflowType: String) -> OstPinVCComponentData {
        
        let contentObj = OstContent.getInstance()
        
        let titleLabel = contentObj.getComponentData(component: .titleLabel,
                                                     inController: controllerType,
                                                     forWorkflow: workflowType)
        
        let leadLabel = contentObj.getComponentData(component: .leadLabel,
                                                    inController: controllerType,
                                                    forWorkflow: workflowType)
        
        let infoLabel = contentObj.getComponentData(component: .infoLabel,
                                                    inController: controllerType,
                                                    forWorkflow: workflowType)
        
        let tcLabel = contentObj.getComponentData(component: .tcLabel,
                                                  inController: controllerType,
                                                  forWorkflow: workflowType)
        
        let placeholders = contentObj.getComponentData(component: .placeholders,
                                                       inController: controllerType,
                                                       forWorkflow: workflowType)
        
        return (titleLabel, leadLabel, infoLabel, tcLabel, placeholders)
    }
    
    class func getPinVCConfigObj(_ componentData: OstPinVCComponentData) -> OstPinVCConfig {
        return OstPinVCConfig(titleLabelData: componentData.titleLabel,
                              leadLabelData: componentData.leadLabel,
                              infoLabelData: componentData.infoLabel,
                              tcLabelData: componentData.tcLabel,
                              placeholders: componentData.placeholders)
    }
    
    
    class func getCreatePinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "create_pin", forWorkflow: "activate_user")
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirmPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "confirm_pin", forWorkflow: "activate_user")
        return getPinVCConfigObj(componentData)
    }
    
    class func getUpdateBiometricPreferencePinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "biometric_preference")
        return getPinVCConfigObj(componentData)
    }
    
    class func getRecoveryAccessPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "initiate_recovery")
        return getPinVCConfigObj(componentData)
    }
    
    class func getAddSessinoPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "add_session")
        return getPinVCConfigObj(componentData)
    }
    
    class func getAbortRecoveryPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "abort_recovery")
        return getPinVCConfigObj(componentData)
    }
    
    class func getPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "reset_pin")
        return getPinVCConfigObj(componentData)
    }
    
    class func getSetNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "set_new_pin", forWorkflow: "reset_pin")
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirmNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "confirm_new_pin", forWorkflow: "reset_pin")
        return getPinVCConfigObj(componentData)
    }
    
    class func getRevokeDevicePinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "revoke_device")
        return getPinVCConfigObj(componentData)
    }
    
    class func getDeviceMnemonicsPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: "get_pin", forWorkflow: "view_mnemonics")
        return getPinVCConfigObj(componentData)
    }
    
    class func getInitiateDeviceVCConfig() -> [String: Any] {
        let config = OstContent.getInstance().getControllerConfig(for: "device_list", inWorkflow: "initiate_recovery")
        return config
    }
    
    class func getRevokeDeviceVCConfig() -> [String: Any] {
        let config = OstContent.getInstance().getControllerConfig(for: "device_list", inWorkflow: "revoke_device")
        return config
    }
    
    class func getShowDeviceMnemonicsVCConfig() -> [String: Any] {
        let config = OstContent.getInstance().getControllerConfig(for: "show_mnemonics", inWorkflow: "view_mnemonics")
        return config
    }
}
