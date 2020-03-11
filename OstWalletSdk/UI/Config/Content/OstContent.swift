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
        bottomLabel,
        placeholders
        
        func getComponentName() -> String {
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
                
            case .bottomLabel:
                return "bottom_label"
                
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
        let component = controllerConfig[component.getComponentName()]
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
        let workflowName = getWorkflowName(for: .activateUser)
        let componentData = getComponentData(inController: "create_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirmPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .activateUser)
        let componentData = getComponentData(inController: "confirm_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getUpdateBiometricPreferencePinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .updateBiometricPreference)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getRecoveryAccessPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .initiateDeviceRecovery)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getAddSessinoPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .addSession)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getAbortRecoveryPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .abortDeviceRecovery)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getPinForResetPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .resetPin)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getSetNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .resetPin)
        let componentData = getComponentData(inController: "set_new_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirmNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .resetPin)
        let componentData = getComponentData(inController: "confirm_new_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getRevokeDeviceVCConfig() -> [String: Any] {
        let workflowName = getWorkflowName(for: .revokeDevice)
        let config = OstContent.getInstance().getControllerConfig(for: "device_list", inWorkflow: workflowName)
        return config
    }
    
    class func getRevokeDevicePinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .revokeDevice)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }

    class func getInitiateDeviceVCConfig() -> [String: Any] {
        let workflowName = getWorkflowName(for: .initiateDeviceRecovery)
        let config = OstContent.getInstance().getControllerConfig(for: "device_list", inWorkflow: workflowName)
        return config
    }
    
    class func getDeviceMnemonicsPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .getDeviceMnemonics)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }

    class func getShowDeviceMnemonicsVCConfig() -> [String: Any] {
        let workflowName = getWorkflowName(for: .getDeviceMnemonics)
        let config = OstContent.getInstance().getControllerConfig(for: "show_mnemonics", inWorkflow: workflowName)
        return config
    }
    
    class func getAddDeviceViaMnemonicsVCConfig() -> [String: Any] {
        let workflowName = getWorkflowName(for: .authorizeDeviceWithMnemonics)
        let config = OstContent.getInstance().getControllerConfig(for: "provide_mnemonics", inWorkflow: workflowName)
        return config
    }
    
    class func getAddDeviceViaMnemonicsPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .authorizeDeviceWithMnemonics)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
    
    class func getShowDeviceQRVCConfig() -> [String: Any]{
        let workflowName = getWorkflowName(for: .showDeviceQR)
        let config = OstContent.getInstance().getControllerConfig(for: "show_qr", inWorkflow: workflowName)
        return config
    }
    
    class func getAuthorizeDeviceViaQRPinVCConfig() -> OstPinVCConfig {
        let workflowName = getWorkflowName(for: .authorizeDeviceWithQRCode)
        let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
        return getPinVCConfigObj(componentData)
    }
	
	class func getAuthorizeSessionViaQRPinVCConfig() -> OstPinVCConfig {
		   let workflowName = getWorkflowName(for: .authorizeSessionWithQRCode)
		   let componentData = getComponentData(inController: "get_pin", forWorkflow: workflowName)
		   return getPinVCConfigObj(componentData)
	}
    
    class func getAuthorizeDeviceVerifyDataVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .authorizeDeviceWithQRCode)
        let viewConfig = OstContent.getInstance().getControllerConfig(for: "verify_device", inWorkflow: workflowName)
        return viewConfig
    }
	
	class func getAuthorizeSessionVerifyDataVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .authorizeSessionWithQRCode)
        let viewConfig = OstContent.getInstance().getControllerConfig(for: "verify_session", inWorkflow: workflowName)
        return viewConfig
    }
    
    class func getExecuteTransactionVerifyDataVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .executeTransaction)
        let viewConfig = OstContent.getInstance().getControllerConfig(for: "verify_transaction", inWorkflow: workflowName)
        return viewConfig
    }
    
    class func getShowQrControllerVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .showDeviceQR)
        let workflowConfig = OstContent.getInstance().getControllerConfig(for: "show_qr", inWorkflow: workflowName)
        return workflowConfig
    }
    
    class func getScanQRForAuthorizeDeviceVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .authorizeDeviceWithQRCode)
        let workflowConfig = OstContent.getInstance().getControllerConfig(for: "scan_qr", inWorkflow: workflowName)
        return workflowConfig
    }
	
	class func getScanQRForAuthorizeSessionVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .authorizeSessionWithQRCode)
        let workflowConfig = OstContent.getInstance().getControllerConfig(for: "scan_qr", inWorkflow: workflowName)
        return workflowConfig
    }
    
    class func getScanQRForExecuteTransactionVCConfig() -> [String: Any] {
        let workflowName = OstContent.getWorkflowName(for: .executeTransaction)
        let workflowConfig = OstContent.getInstance().getControllerConfig(for: "scan_qr", inWorkflow: workflowName)
        return workflowConfig
    }
    
    class func getLoaderText(for type: OstWorkflowType) -> String {
        
        let content = OstContent.getInstance()
        let workflowName = getWorkflowName(for: type)
        
        let loaderConfig = content.getControllerConfig(for: "loader", inWorkflow: workflowName)
        if let text = loaderConfig["text"] as? String {
            
            return text
        }
        return "Processing..."
    }
    
    class func getInitialLoaderText(for type: OstWorkflowType) -> String {
        
        let content = OstContent.getInstance()
        let workflowName = getWorkflowName(for: type)
        
        let loaderConfig = content.getControllerConfig(for: "initial_loader", inWorkflow: workflowName)
        if let text = loaderConfig["text"] as? String {
            
            return text
        }
        return "Initializing..."
    }
	
	class func getAcknowledgeText(for type: OstWorkflowType) -> String {
        
        let content = OstContent.getInstance()
        let workflowName = getWorkflowName(for: type)
        
        let loaderConfig = content.getControllerConfig(for: "acknowledge", inWorkflow: workflowName)
        if let text = loaderConfig["text"] as? String {
            
            return text
        }
        return "Waiting for confirmation..."
    }
    
    class func getWorkflowName(for workflowType: OstWorkflowType) -> String {
        switch workflowType {
        case .activateUser:
            return "activate_user"
            
        case .addSession:
            return "add_session"
            
        case .abortDeviceRecovery:
            return "abort_recovery"
            
        case .getDeviceMnemonics:
            return "view_mnemonics"
            
        case .initiateDeviceRecovery:
            return "initiate_recovery"
            
        case .resetPin:
            return "reset_pin"

        case .revokeDevice:
            return "revoke_device"
            
        case .updateBiometricPreference:
            return "biometric_preference"
            
        case .authorizeDeviceWithMnemonics:
            return "add_current_device_with_mnemonics"
            
        case .showDeviceQR:
            return "show_add_device_qr"
            
        case .authorizeDeviceWithQRCode:
            return "scan_qr_to_authorize_device"
        
        case .executeTransaction:
            return "scan_qr_to_execute_transaction"
		case .authorizeSessionWithQRCode:
            return "scan_qr_to_authorize_session"
        default:
            return ""
        }
    }
}
