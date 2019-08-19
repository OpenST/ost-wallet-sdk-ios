/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstGetMnemonicsWorkflowController: OstBaseWorkflowController {
 
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("ui_u_wc_gmwc_pudv_1", .deviceNotAuthorized)
        }
    }
    override func performUIActions() {
        OstWalletSdk.getDeviceMnemonics(userId: self.userId,
                                        delegate: self)
        showLoader(for: .getDeviceMnemonics)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getDeviceMnemonicsPinVCConfig()
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .getDeviceMnemonics)
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    @objc override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .getDeviceMnemonics)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.getPinViewController) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_gmwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    override func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        if workflowContext.workflowType == .getDeviceMnemonics {
            openDeviceMnemonicsViewController(contextEntity: ostContextEntity)
        }
        
        super.flowComplete(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
    }
    
    func openDeviceMnemonicsViewController(contextEntity: OstContextEntity) {
        DispatchQueue.main.async {
            let deviceMnemonicsViewController = OstDeviceMnemonicsViewController
                .newInstance(mnemonics: contextEntity.entity as! [String])
            
            deviceMnemonicsViewController.presentVCWithNavigation()
        }
    }
}
