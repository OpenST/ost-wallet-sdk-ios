/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstGetMnemonicsWorkflowController: OstBaseWorkflowController {
  
    @objc
    init(userId: String, passphrasePrefixDelegate: OstPassphrasePrefixDelegate?) {
        super.init(userId: userId,
                   passphrasePrefixDelegate: passphrasePrefixDelegate,
                   workflowType: .getDeviceMnemonics)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.getPinViewController) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_gmwc_vimfp_1", .userCanceled))
            }else if (nil != (notification.object! as? OstDeviceMnemonicsViewController)) {
				dismissWorkflow()
			}
        }
    }

    override func performUIActions() {
        OstWalletSdk.getDeviceMnemonics(userId: self.userId,
                                        delegate: self)
        showInitialLoader(for: .getDeviceMnemonics)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getDeviceMnemonicsPinVCConfig()
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    @objc override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .getDeviceMnemonics)
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
    
    override func showOnSuccess(workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
		cleanUpPinViewController()
		hideLoader()
        //ShowOnSuccess got consumed in this workflow.
        //No need to broadcast to show success alert as we are the one who is showing mnemonics.
    }
}
