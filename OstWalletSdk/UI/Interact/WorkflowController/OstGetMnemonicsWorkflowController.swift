/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstGetMnemonicsWorkflowController: OstBaseWorkflowController {
 
    var deviceMnemonicsViewController: OstDeviceMnemonicsViewController? = nil
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("ui_u_wc_gmwc_pudv_1", .deviceNotAuthorized)
        }
    }
    override func performUIActions() {
        OstWalletSdk.getDeviceMnemonics(userId: self.userId,
                                        delegate: self)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig.getDeviceMnemonicsPinVCConfig()
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .getDeviceMnemonics)
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    @objc override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(progressText: .fetchingDeviceMnemonics)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.deviceMnemonicsViewController) {
                OstSdkInteract.getInstance.removeEventListners(forWorkflowId: self.workflowId)
                cleanUp()
            }else if ((notification.object! as? OstBaseViewController) === self.getPinViewController) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_gmwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    override func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        hideLoader()
        if workflowContext.workflowType == .getDeviceMnemonics {
            openDeviceMnemonicsViewController(contextEntity: ostContextEntity)
        }
    }
    
    func openDeviceMnemonicsViewController(contextEntity: OstContextEntity) {
        DispatchQueue.main.async {
            self.deviceMnemonicsViewController = OstDeviceMnemonicsViewController
                .newInstance(mnemonics: contextEntity.entity as! [String],
                             onClose: {[weak self] in
                                self?.cleanUp()
                })
            
            if nil == self.getPinViewController {
                self.deviceMnemonicsViewController?.presentVCWithNavigation()
            }else {
                self.deviceMnemonicsViewController?.pushViewControllerOn(self.getPinViewController!)
            }
        }
    }
    
    override func cleanUp() {
        if nil != deviceMnemonicsViewController {
            deviceMnemonicsViewController?.removeViewController(flowEnded: true)
        }else if nil != getPinViewController {
            getPinViewController?.removeViewController(flowEnded: true)
        }
        
        deviceMnemonicsViewController = nil
        getPinViewController = nil
        passphrasePrefixDelegate = nil
        NotificationCenter.default.removeObserver(self)
        super.cleanUp()
    }
}
