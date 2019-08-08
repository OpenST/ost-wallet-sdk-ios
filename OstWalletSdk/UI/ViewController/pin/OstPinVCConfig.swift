/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstPinVCConfig: NSObject {
    
    let titleLabelData: Any?
    let leadLabelData: Any?
    let infoLabelData: Any?
    let tcLabelData: Any?
    let placeholders: Any?
    
    init(titleLabelData: Any?,
         leadLabelData: Any?,
         infoLabelData: Any?,
         tcLabelData: Any?,
         placeholders: Any?) {
        
        self.titleLabelData = titleLabelData
        self.leadLabelData = leadLabelData
        self.infoLabelData = infoLabelData
        self.tcLabelData = tcLabelData
        self.placeholders = placeholders
        
        super.init()
    }
    
    func getText(from data: Any?) -> String {
        if let dict = data as? [String: Any],
            let text = dict["text"] as? String {
            return text
        }
        
        return ""
    }
    
    func getFont(from data: Any?, ofSize size: CGFloat) -> UIFont? {
        if let dict = data as? [String: Any],
            let fontName = dict["font"] as? String {
            return UIFont(name: fontName, size: size)
        }
        return nil
    }
    
    func getForegroundColor(from data: Any?) -> UIColor? {
        if let dict = data as? [String: Any],
            let colorHex = dict["color"] as? String {
            return UIColor.color(hex: colorHex)
        }
        return nil
    }
    
    func updateLabelWithAttributedText(label: OstLabel, data: Any?) {
        //Get text from config
        let labelText = getText(from: data)
        //Get font from. config if font is not present, default would be label config font.
        let labelFont = getFont(from: data, ofSize: CGFloat(truncating: label.labelConfig!.size)) ?? label.labelConfig!.getFont()
        //Get foreground color from config. if foreground is not present, default would be label config foreground.
        let labelForegroundColor = getForegroundColor(from: data) ?? label.labelConfig!.getColor()
        
        //Defaut text attribute
        let attributes: [NSAttributedString.Key : Any] = [.font: labelFont,
                                                          .foregroundColor: labelForegroundColor]
        
        let finalAttributedText: NSMutableAttributedString = NSMutableAttributedString()
    
        let splitWords = labelText.split(separator: " ")
        
        var combinedWords: String = ""
        for word in splitWords {
            //chekc whether word has {{ and }}
            if word.hasPrefix("{{") && word.hasSuffix("}}") {
                //clear {{ and }}
                var newAttributedText: String = String(word.replacingOccurrences(of: "{{", with: ""))
                newAttributedText = String(newAttributedText.replacingOccurrences(of: "}}", with: ""))
                
                //Get data for placeholder text from {{KEY_FOR_TEXT}}
                var placeHoderDict: [String: Any]? = nil
                if let dict = placeholders as? [String: Any] {
                    placeHoderDict = dict[newAttributedText] as? [String: Any]
                }
                
                if nil != placeHoderDict {
                    //Assign attributed text.
                    let attibutedString = NSAttributedString(string: combinedWords,
                                                             attributes: attributes)
                    finalAttributedText.append(attibutedString)
                    
                    combinedWords = ""
                    
                    //Set fonts for placeholder. default is label font
                    var font = labelFont
                    
                    //Set foregroundColor for placeholder. default is label foregroundColor
                    var foregroundColor = labelForegroundColor
                    if let placeHolderFont =  getFont(from: placeHoderDict, ofSize: CGFloat(truncating: label.labelConfig!.size)) {
                        font = placeHolderFont
                    }
                    
                    if let placeHoderForegroundColor = getForegroundColor(from: placeHoderDict) {
                        foregroundColor = placeHoderForegroundColor
                        placeHoderDict!["color"] = nil
                    }
                    //Create new attriutes for placeholder.
                    var newAttributes: [NSAttributedString.Key : Any] = [.font: font,
                                                                         .foregroundColor: foregroundColor]
                    //Set extra keys in attributes
                    for (key, val) in placeHoderDict! {
                        newAttributes[.init(key)] = val
                    }
                    let text = getText(from: placeHoderDict!)
                    let newAttributedString = NSAttributedString(string: "\(text) ", attributes: newAttributes)
                
                    finalAttributedText.append(newAttributedString)
                }
            }else {
                combinedWords += "\(word) "
            }
        }
        
        if combinedWords.count > 0 {
            let attibutedString = NSAttributedString(string: combinedWords,
                                                     attributes: attributes)
            finalAttributedText.append(attibutedString)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        finalAttributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, finalAttributedText.length))
        
        label.attributedText = finalAttributedText
    }
}

extension OstPinVCConfig {
    typealias OstComponentData = (titleLabel: [String: Any]?,
        leadLabel: [String: Any]?,
        infoLabel: [String: Any]?,
        tcLabel: [String: Any]?,
        placeholders: [String: Any]?)
    
    class func getComponentData(inController controllerType: String,
                                forWorkflow workflowType: String) -> OstComponentData {
        
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
    
    class func getPinVCConfigObj(_ componentData: OstComponentData) -> OstPinVCConfig {
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
}
