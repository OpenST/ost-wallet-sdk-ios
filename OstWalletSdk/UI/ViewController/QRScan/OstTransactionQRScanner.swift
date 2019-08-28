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
                           onSuccessScanning: ((String?) -> Void)?,
                           onErrorScanning: ((OstError?) -> Void)?) -> OstTransactionQRScanner {
        
        let vc = OstTransactionQRScanner()
        vc.userId = userId
        vc.onSuccessScanning = onSuccessScanning
        vc.onErrorScanning = onErrorScanning
        return vc
    }
    
    override func configure() {
        
        let pageConfig = OstContent.getScanQRForExecuteTransactionVCConfig()
        titleLabel.updateAttributedText(data: pageConfig[OstContent.OstComponentType.titleLabel.getComponentName()],
                                        placeholders: pageConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        super.configure()
    }

    override func onQRCodeDataReceived(_ data:[String]?) {
        super.onQRCodeDataReceived(data)
        
        if isValidQR() {
            let qrData = qrDataString![0]
            onSuccessScanning?(qrData)
        }else {
            onErrorScanning?(OstError("ui_vc_qrs_adqrs_qrcdr_1", .invalidQRCode))
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
            let validRuleNames = [OstExecuteTransactionType.DirectTransfer.getQRText().lowercased(),
                                  OstExecuteTransactionType.Pay.getQRText().lowercased()]
            
            if !validRuleNames.contains(executeTxPayloadParams!.ruleName.lowercased()) {
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
