/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeExteranSessionViaQRCodeWorkflowController: OstBaseWorkflowController {
	var authorizeSessionQRScannerVC: OstAuthorizeSessionQRScanner? = nil
	var validateDataDelegate: OstValidateDataDelegate? = nil
	var verfiyAuthSessionVC: OstVerifyAuthorizeSession? = nil
	
	var showFailureAlert = false;

	@objc init(userId: String, passphrasePrefixDelegate: OstPassphrasePrefixDelegate?) {
		super.init(userId: userId,
				   passphrasePrefixDelegate: passphrasePrefixDelegate,
				   workflowType: .authorizeSessionWithQRCode)
	}
	
	override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.authorizeSessionQRScannerVC) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_adqrwc_vimfp_1", .userCanceled))
                
            }else if (nil != self.getPinViewController && nil != self.sdkPinAcceptDelegate) {
                if (notification.object as? OstBaseViewController) === getPinViewController! {
                    self.sdkPinAcceptDelegate?.cancelFlow()
                }
            }
        }
    }
	
	override func performUIActions() {
		openQRScannerForAuthorizeSessionVC()
	}
	
	override func shouldShowFailureAlert() -> Bool {
		let storedVal = self.showFailureAlert
		self.showFailureAlert = false
		return storedVal
	}
	
	func openQRScannerForAuthorizeSessionVC() {
        DispatchQueue.main.async {
            self.authorizeSessionQRScannerVC = OstAuthorizeSessionQRScanner
                .newInstance(onSuccessScanning: {[weak self] (scannedData) in
                        if nil != scannedData {
                            self?.onScanndedDataReceived(scannedData!)
                        }
                    }, onErrorScanning: {[weak self] (error) in
                        let ostError = error ?? OstError("ui_i_wc_aesvqrwc_oqrsfasvc_1", OstErrorCodes.OstErrorCode.unknown)
						self?.showFailureAlert = true
						self?.postFlowInterrupted(error: ostError);
                })
            
            self.authorizeSessionQRScannerVC?.presentVCWithNavigation()
        }
    }
	
	func onScanndedDataReceived(_ data: String) {
        OstWalletSdk.performQRAction(userId: self.userId, payload: data, delegate: self)
        showInitialLoader(for: .authorizeDeviceWithQRCode)
    }
	
	override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getAuthorizeSessionViaQRPinVCConfig()
    }
	
	@objc override func showPinViewController() {
		   self.getPinViewController?.pushViewControllerOn(self.authorizeSessionQRScannerVC!)
	}
	
	override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .authorizeSessionWithQRCode)
    }
	
	override func verifyData(workflowContext: OstWorkflowContext,
                             ostContextEntity: OstContextEntity,
                             delegate: OstValidateDataDelegate) {
        
        validateDataDelegate = delegate
        if workflowContext.workflowType == .authorizeSessionWithQRCode {
            openVerifyAuthSessionVC(ostContextEntity: ostContextEntity)
        }else {
            delegate.cancelFlow()
        }
    }
	
	func openVerifyAuthSessionVC(ostContextEntity: OstContextEntity) {
        DispatchQueue.main.async {
            self.hideLoader()
            self.verfiyAuthSessionVC = OstVerifyAuthorizeSession
                .newInstance(session: ostContextEntity.entity as! OstSession,
                             authorizeCallback: {[weak self] (_) in

                                self?.showLoader(for: .authorizeSessionWithQRCode)
                                self?.validateDataDelegate?.dataVerified()

                }) {[weak self] in
                    self?.validateDataDelegate?.cancelFlow()
            }
            
            self.verfiyAuthSessionVC!.presentVC(animate: false)
        }
    }
	
	override func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
		   if error.messageTextCode == OstErrorCodes.OstErrorCode.userCanceled
			   && (nil != verfiyAuthSessionVC || nil != getPinViewController ) {
			   
			   verfiyAuthSessionVC = nil
			   getPinViewController = nil
			   hideLoader()
			   authorizeSessionQRScannerVC?.scannerView?.startScanning()
		   }else {
			   super.flowInterrupted(workflowContext: workflowContext, error: error)
		   }
	   }
	
	override func cleanUp() {
        authorizeSessionQRScannerVC?.removeViewController(flowEnded: true)
        authorizeSessionQRScannerVC = nil
        validateDataDelegate = nil
        verfiyAuthSessionVC?.dismissVC()
        verfiyAuthSessionVC = nil
        super.cleanUp()
    }
}
