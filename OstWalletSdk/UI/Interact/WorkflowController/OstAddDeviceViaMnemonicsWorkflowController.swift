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
    
    @objc
    init(userId: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate?) {
        
        super.init(userId: userId,
                   passphrasePrefixDelegate: passphrasePrefixDelegate,
                   workflowType: .authorizeDeviceWithMnemonics)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.addDeviceViaMnemonicsViewController) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_advmwc_vimfp_1", .userCanceled))
            }else if (nil != self.getPinViewController
                && nil != self.sdkPinAcceptDelegate) {
                
                if (notification.object as? OstBaseViewController) === getPinViewController! {
                    sdkPinAcceptDelegate?.cancelFlow()
                }
            }
        }
    }
    
    override func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return false
    }
    
    override func performUIActions() {
        openGetMnemonicsViewController()
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
    
    override func cleanUp() {
        self.addDeviceViaMnemonicsViewController?.removeViewController(flowEnded: true)
        self.addDeviceViaMnemonicsViewController = nil
        super.cleanUp()
    }
    
    override func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        if error.messageTextCode == OstErrorCodes.OstErrorCode.userCanceled
            && nil != getPinViewController {
            getPinViewController = nil
            hideLoader()
        }else {
            super.flowInterrupted(workflowContext: workflowContext, error: error)
        }
    }
}
