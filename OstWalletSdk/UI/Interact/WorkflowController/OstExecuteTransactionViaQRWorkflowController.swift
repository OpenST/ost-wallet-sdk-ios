/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstExecuteTransactionViaQRWorkflowController: OstBaseWorkflowController {
    
    
    var executeTransactionQRScannerVC: OstTransactionQRScanner? = nil
    var validateDataDelegate: OstValidateDataDelegate? = nil
    var verfiyAuthDeviceVC: OstVerifyTransaction? = nil

    @objc
    init(userId: String) {
        super.init(userId: userId, passphrasePrefixDelegate: nil, workflowType: .executeTransaction)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.executeTransactionQRScannerVC) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_etvqrwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    override func performUIActions() {
        openScanQRForExecuteTransctionVC()
    }
    
    func openScanQRForExecuteTransctionVC() {
        DispatchQueue.main.async {
            self.executeTransactionQRScannerVC = OstTransactionQRScanner
                .newInstance(
                    userId: self.userId,
                    onSuccessScanning: {[weak self] (scannedData) in
                        if nil != scannedData {
                            self?.onScanndedDataReceived(scannedData!)
                        }
                    })
            
            self.executeTransactionQRScannerVC?.presentVCWithNavigation()
        }
    }
    
    func onScanndedDataReceived(_ data: String) {
        OstWalletSdk.performQRAction(userId: self.userId, payload: data, delegate: self)
        showLoader(for: .executeTransaction)
    }
    
    override func verifyData(workflowContext: OstWorkflowContext,
                             ostContextEntity: OstContextEntity,
                             delegate: OstValidateDataDelegate) {
        
        validateDataDelegate = delegate
        if workflowContext.workflowType == .executeTransaction {
            openVerifyExecuteTxVC(ostContextEntity: ostContextEntity)
        }else {
            delegate.cancelFlow()
        }
    }
    
    func openVerifyExecuteTxVC(ostContextEntity: OstContextEntity) {
        DispatchQueue.main.async {
            guard let qrData = ostContextEntity.entity as? [String: Any] else {
                self.validateDataDelegate?.cancelFlow()
                return
            }
            self.verfiyAuthDeviceVC = OstVerifyTransaction
                .newInstance(
                    userId: self.userId,
                    qrData: qrData,
                    authorizeCallback: {[weak self] (data) in
                        self?.showLoader(for: .executeTransaction)
                        self?.validateDataDelegate?.dataVerified()
                    
                    },
                    cancelCallback: {[weak self] in
                        self?.validateDataDelegate?.cancelFlow()
                    },
                    hideLoaderCallback: {[weak self] in
                        self?.hideLoader()
                    },
                    errorCallback: {[weak self] (error) in
                        let ostError = error ?? OstError("ui_i_wc_etvqrwc_ovetxvc_1", OstErrorCodes.OstErrorCode.unknown)
                        self?.postFlowInterrupted(error: ostError)
                    }
                )
            
            self.verfiyAuthDeviceVC!.presentVC(animate: false)
        }
    }
    
    override func cleanUp() {
        executeTransactionQRScannerVC?.removeViewController(flowEnded: true)
        executeTransactionQRScannerVC = nil
        validateDataDelegate = nil
        verfiyAuthDeviceVC?.dismissVC()
        verfiyAuthDeviceVC = nil
        super.cleanUp()
    }
    
}
