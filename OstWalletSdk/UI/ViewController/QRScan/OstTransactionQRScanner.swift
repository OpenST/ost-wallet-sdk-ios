/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class OstTransactionQRScanner: OstBaseQRScannerViewController {
    
    class func newInstance(userId: String,
                           onSuccessScanning: ((String?) -> Void)?) -> OstTransactionQRScanner {
        let vc = OstTransactionQRScanner()
        vc.userId = userId
        vc.onSuccessScanning = onSuccessScanning
        return vc
    }

    override func onQRCodeDataReceived(_ data:[String]?) {
        super.onQRCodeDataReceived(data)
        
        if isValidQR() {
            let qrData = qrDataString![0]
            onSuccessScanning?(qrData)
        }else {
            showAlert(title: "Invalid QR-Code",
                      message: "QR-Code scanned for executing transaction is invalid. Please scan valid QR-Code to executing transaction.",
                      buttonTitle: "Scan Again",
                      cancelButtonTitle: "Cancel",
                      actionHandler: {[weak self] (alertAction) in
                        
                        self?.scannerView?.startScanning()
            }) {[weak self] (alertAction) in
                self?.onCancelScanning?()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func isValidQR() -> Bool {
        if (nil != qrDataString)
            && (qrDataString!.count > 0 ){
            
            let qrData = qrDataString![0]
            guard let payloadData = getpaylaodDataFromQR(qrData) else {
                return false
            }
            let executeTxPayloadParams = try? OstExecuteTransaction.getExecuteTransactionParamsFromQRPayload(payloadData)
            let currentUser = try? OstUser.getById(self.userId!)!
            if nil == executeTxPayloadParams || nil == currentUser {
                return false
            }
        
            if (currentUser!.tokenId! != executeTxPayloadParams!.tokenId) {
                return false
            }
            
            return true
        }
        
        return false
    }
    
    override func getDataDefination() -> String {
        return OstQRCodeDataDefination.TRANSACTION.rawValue
    }
}
