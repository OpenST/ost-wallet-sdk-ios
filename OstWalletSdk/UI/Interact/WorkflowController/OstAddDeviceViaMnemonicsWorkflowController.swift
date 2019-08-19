/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddDeviceViaMnemonicsWorkflowController: OstBaseWorkflowController {
    
    var addDeviceViaMnemonicsViewController: OstAddDeviceViaMnemonicsViewController? = nil
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusRegistered {
            throw OstError("ui_i_wc_advmwc_pudv_1", .deviceCanNotBeAuthorized)
        }
    }
    override func performUIActions() {
        openGetMnemonicsViewController()
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.addDeviceViaMnemonicsViewController) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_advmwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    func openGetMnemonicsViewController() {
        DispatchQueue.main.async {
            self.addDeviceViaMnemonicsViewController = OstAddDeviceViaMnemonicsViewController
                .newInstance(onActionTapped: {[weak self] (mnemonicsString) in
                
                    self?.onMnemonicsReceived(mnemonicsString: mnemonicsString)
            })
            
            self.addDeviceViaMnemonicsViewController?.presentVCWithNavigation()
        }
    }
    
    func onMnemonicsReceived(mnemonicsString: String) {
        let mnemonicsArray: [String] = mnemonicsString.components(separatedBy: " ")
        OstWalletSdk.authorizeCurrentDeviceWithMnemonics(userId: self.userId,
                                                         mnemonics: mnemonicsArray,
                                                         delegate: self)
        
        showLoader(for: .authorizeDeviceWithMnemonics)
    }
    
    @objc override func showPinViewController() {
        self.getPinViewController?.pushViewControllerOn(self.addDeviceViaMnemonicsViewController!)
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .authorizeDeviceWithMnemonics)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getAddDeviceViaMnemonicsPinVCConfig()
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .authorizeDeviceWithMnemonics)
    }
    
    override func cleanUp() {
        self.addDeviceViaMnemonicsViewController?.removeViewController(flowEnded: true)
        self.addDeviceViaMnemonicsViewController = nil
        super.cleanUp()
    }
}
