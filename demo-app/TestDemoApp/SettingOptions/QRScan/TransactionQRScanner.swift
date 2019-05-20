/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class TransactionQRScanner: QRScannerViewController {
    
    override func getLeadLabelText() -> String {
        return "Scan the transaction QR code to transfer"
    }
    
    override func scannedQRData(_ qrData: String) {
        if isValidQRdata(qrData) {
            super.scannedQRData(qrData)
        }else {
            let alert = UIAlertController(title: "Invalid QR-Code",
                                          message: "QR-Code scanned for executing transaction is invalid. Please scan valid QR-Code to executing transaction.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ScanAgain", style: .default, handler: {[weak self] (alertAction) in
                self?.scanner?.startScanning()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isValidQRdata(_ qrData: String) -> Bool {
        guard let payloadData = getpaylaodDataFromQR(qrData),
            let addresses =  payloadData["ads"] as? [String],
            let amounts = payloadData["ams"] as? [String] else{
            
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
}
