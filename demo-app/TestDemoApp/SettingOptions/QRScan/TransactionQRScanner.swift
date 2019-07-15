/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class TransactionQRScanner: QRScannerViewController {
    
    override func getLeadLabelText() -> String {
        return "Scan the QR code to complete the transaction"
    }
    
    override func scannedQRData(_ qrData: String) {
        if isValidQRdata(qrData) {
            super.scannedQRData(qrData)
        }else {
            let alert = UIAlertController(title: "Invalid QR-Code",
                                          message: "QR-Code scanned for executing transaction is invalid. Please scan valid QR-Code to executing transaction.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Scan Again", style: .default, handler: {[weak self] (alertAction) in
                self?.scanner?.startScanning()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {[weak self] (alertAction) in
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isValidQRdata(_ qrData: String) -> Bool {
        guard let payloadData = getpaylaodDataFromQR(qrData),
            let ruleName = payloadData["rn"] as? String,
            let addresses =  payloadData["ads"] as? [String],
            let amounts = payloadData["ams"] as? [String] else{
                
                return false
        }
        
        if ![OstExecuteTransactionType.DirectTransfer.getQRText().lowercased(),
            OstExecuteTransactionType.Pay.getQRText().lowercased()].contains(ruleName.lowercased()) {
            
            return false
        }
        
        let filteredAddress = addresses.filter({
            let address = $0.replacingOccurrences(of: " ", with: "")
            return !address.isEmpty
        })
        
        let filteredAmounts = amounts.filter({
            return $0.isMatch("^[0-9]*$")
        })
        
        return (filteredAddress.count > 0) && (filteredAddress.count == filteredAmounts.count) 
    }
    
    override func validDataDefination() -> String {
        return "tx"
    }
    
    override func showProgressIndicator() {
        progressIndicator = OstProgressIndicator(textCode: .executingTransaction)
        progressIndicator?.show()
    }
    
    
    //MARK: - Workflow Delegate
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        showSuccessAlert(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    //MARK
    override func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
        progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                            onCompletion: {[weak self] (_) in
                                                
                                                self?.onFlowComplete(workflowId: workflowId,
                                                                     workflowContext: workflowContext,
                                                                     contextEntity: contextEntity)
        })
    }
    
    override func onFlowComplete(workflowId: String,
                                 workflowContext: OstWorkflowContext,
                                 contextEntity: OstContextEntity) {
        
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.tabBarVC?.jumpToWalletVC(withWorkflowId: workflowId)
        })
    }
    
    override func onFlowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
