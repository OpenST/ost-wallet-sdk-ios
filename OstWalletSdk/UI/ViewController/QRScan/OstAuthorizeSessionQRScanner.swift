/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeSessionQRScanner: OstBaseQRScannerViewController {
	
	class func newInstance(onSuccessScanning: ((String?) -> Void)?,
                           onErrorScanning: ((OstError?) -> Void)?) -> OstAuthorizeSessionQRScanner {
        
        let vc = OstAuthorizeSessionQRScanner()
        vc.onSuccessScanning = onSuccessScanning
        vc.onErrorScanning = onErrorScanning
        
        return vc
    }
	
	override func configure() {
		let pageConfig = OstContent.getScanQRForAuthorizeDeviceVCConfig()
		titleLabel.updateAttributedText(data: pageConfig[OstContent.OstComponentType.titleLabel.getComponentName()],
										placeholders: pageConfig[OstContent.OstComponentType.placeholders.getComponentName()])
		   
		super.configure()
	}
	
	func isValidQR() -> Bool {
        if (nil != qrDataString)
            && (qrDataString!.count > 0 ){
            
            let qrData = qrDataString![0]
            if let payloadData = getpaylaodDataFromQR(qrData),
                let _ = try? OstAddSessionWithQRData.getAddSessionParamsFromQRPayload(payloadData) {
                    return true
            }
        }
        
        return false
    }
	
	override func getDataDefination() -> String {
		   return OstQRCodeDataDefination.AUTHORIZE_SESSION.rawValue
	}
}
