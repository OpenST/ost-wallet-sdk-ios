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
    
    func updateLabelWithAttributedText(label: OstLabel, data: Any?) {
        let labelText = getText(from: data)
        
        let labelFont = label.labelConfig!.getFont()
        let labelForegroundColor = label.labelConfig!.getColor()
        let attributes: [NSAttributedString.Key : Any] = [.font: labelFont,
                                                          .foregroundColor: labelForegroundColor]
        
        let finalAttributedText: NSMutableAttributedString = NSMutableAttributedString()
    
        let splitWords = labelText.split(separator: " ")
        
        var combinedWords: String = ""
        for word in splitWords {
            if word.hasPrefix("{{") && word.hasSuffix("}}") {
                
                var newAttributedText: String = String(word.replacingOccurrences(of: "{{", with: ""))
                newAttributedText = String(newAttributedText.replacingOccurrences(of: "}}", with: ""))
                
                var placeHoderDict: [String: Any]? = nil
                if let dict = placeholders as? [String: Any] {
                    placeHoderDict = dict[newAttributedText] as? [String: Any]
                }
                if nil != placeHoderDict {
                    
                    //craete attributed text
                    let attibutedString = NSAttributedString(string: combinedWords,
                                                             attributes: attributes)
                    finalAttributedText.append(attibutedString)
                    
                    combinedWords = ""
                    
                    var font = labelFont
                    var foregroundColor = labelForegroundColor
                    if let placeHolderFont = placeHoderDict!["font"] as? String {
                        font = label.labelConfig!.getFont(font: placeHolderFont)
                        placeHoderDict!["font"] = nil
                    }
                    
                    if let placeHoderForegroundColor = placeHoderDict!["color"] as? String {
                        foregroundColor = UIColor.color(hex: placeHoderForegroundColor)
                        placeHoderDict!["color"] = nil
                    }
                    
                    var newAttributes: [NSAttributedString.Key : Any] = [.font: font,
                                                                         .foregroundColor: foregroundColor]
                    
                    for (key, val) in placeHoderDict! {
                        newAttributes[.init(key)] = val
                    }
                    let text = getText(from: placeHoderDict!)
                    let newAttributedString = NSAttributedString(string: " \(text) ", attributes: newAttributes)
                
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
    
    class func getComponentData(inController controllerType: OstContent.OstContentControllerType,
                                forWorkflow workflowType: OstContent.OstContnetWorkflowType) -> OstComponentData {
        
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
        let componentData = getComponentData(inController: .createPin, forWorkflow: .activateUser)
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirmPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .activateUser)
        return getPinVCConfigObj(componentData)
    }
    
    class func getUpdateBiometricPreferencePinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getRecoveryAccessPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getAddSessinoPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getAbortRecoveryPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getSetNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
    
    class func getConfirnNewPinForResetPinVCConfig() -> OstPinVCConfig {
        let componentData = getComponentData(inController: .confirmPin, forWorkflow: .updateBiometricPreference)
        return getPinVCConfigObj(componentData)
    }
}
