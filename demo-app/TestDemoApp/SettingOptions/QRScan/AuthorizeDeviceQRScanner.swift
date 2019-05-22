/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class AuthorizeDeviceQRScanner: QRScannerViewController {
    
    override func scannedQRData(_ qrData: String) {
        if isValidQRdata(qrData) {
            super.scannedQRData(qrData)
        }else {
            let alert = UIAlertController(title: "Invalid QR-Code",
                                          message: "QR-Code scanned for authorize device is invalid. Please scan valid QR-Code to authorize device.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ScanAgain", style: .default, handler: {[weak self] (alertAction) in
                self?.scanner?.startScanning()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isValidQRdata(_ qrData: String) -> Bool {
        guard let payloadData = getpaylaodDataFromQR(qrData),
                let _ =  payloadData["da"] as? String else {
                    
                    return false
        }
        
        return true
    }
    
    override func validDataDefination() -> String {
        return "ad"
    }
}

