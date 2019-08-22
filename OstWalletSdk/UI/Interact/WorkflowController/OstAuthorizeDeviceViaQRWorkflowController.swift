/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeDeviceViaQRWorkflowController: OstBaseWorkflowController {
    
    var authorizeDeviceQRScannerVC: OstAuthorizeDeviceQRScanner? = nil
    var validateDataDelegate: OstValidateDataDelegate? = nil
    
    @objc
    init(userId: String, passphrasePrefixDelegate: OstPassphrasePrefixDelegate?) {
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate, workflowType: .authorizeDeviceWithQRCode)
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !currentDevice!.isStatusAuthorized {
            throw OstError("ui_i_wc_adqrwc_pudv_1", .deviceNotAuthorized)
        }
    }
    
    override func performUIActions() {
        openScanQRForAuthorizeDeviceVC()
    }
    
    func openScanQRForAuthorizeDeviceVC() {
        DispatchQueue.main.async {
            self.authorizeDeviceQRScannerVC = OstAuthorizeDeviceQRScanner
                .newInstance(onSuccessScanning: {[weak self] (scannedData) in
                    if nil != scannedData {
                        self?.onScanndedDataReceived(scannedData!)
                    }
                    })
            
            self.authorizeDeviceQRScannerVC?.presentVCWithNavigation()
        }
    }
    
    func onScanndedDataReceived(_ data: String) {
        OstWalletSdk.performQRAction(userId: self.userId, payload: data, delegate: self)
        showLoader(for: .authorizeDeviceWithQRCode)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getAuthorizeDeviceViaQRPinVCConfig()
    }
    
    @objc override func showPinViewController() {
        self.getPinViewController?.pushViewControllerOn(self.authorizeDeviceQRScannerVC!)
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .authorizeDeviceWithQRCode)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.authorizeDeviceQRScannerVC) {
               self.postFlowInterrupted(error: OstError("ui_i_wc_adqrwc_vimfp_1", .userCanceled))
            }
        }
    }

    override func cleanUp() {
        authorizeDeviceQRScannerVC?.removeViewController(flowEnded: true)
        authorizeDeviceQRScannerVC = nil
        validateDataDelegate = nil
        super.cleanUp()
    }
    
    override func verifyData(workflowContext: OstWorkflowContext,
                             ostContextEntity: OstContextEntity,
                             delegate: OstValidateDataDelegate) {
        
        validateDataDelegate = delegate
        if workflowContext.workflowType == .authorizeDeviceWithQRCode {
            openVerifyAuthDeviceVC(ostContextEntity: ostContextEntity)
        }else {
            delegate.cancelFlow()
        }
    }
    
    func openVerifyAuthDeviceVC(ostContextEntity: OstContextEntity) {
        DispatchQueue.main.async {
            self.hideLoader()
            let verfiyAuthDeviceVC = OstVerifyAuthorizeDevice
                .newInstance(device: ostContextEntity.entity as! OstDevice,
                             authorizeCallback: {[weak self] (_) in

                                self?.showLoader(for: .authorizeDeviceWithQRCode)
                                self?.validateDataDelegate?.dataVerified()

                }) {[weak self] in
                    self?.validateDataDelegate?.cancelFlow()
            }
            
            verfiyAuthDeviceVC.presentVC(animate: false)
        }
    }
}
