//
//  QRScannerViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import AVFoundation

class OstBaseQRScannerViewController: OstBaseViewController {
    
    let titleLabel: OstH1Label = OstH1Label()
    var scannerView: OstScannerView? = nil
    
    var onSuccessScanning: ((String?) -> Void)? = nil
    var onCancelScanning: (() -> Void)? = nil
    var onErrorScanning: ((OstError?) -> Void)? = nil
    
    var qrDataString: [String]? = nil
    var qrPayloadData: [String: Any?]? = nil
    var qrMeta: [String: Any?]? = nil
    
    override func configure() {
        super.configure()
        
        scannerView = OstScannerView(completion: {[weak self] (qrDataArray) in
            self?.onQRCodeDataReceived(qrDataArray)
        })
        self.shouldFireIsMovingFromParent = true
    }
    
    //MARK: - View LC
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scannerView?.startScanning()
    }
    
    //MARK: - Add Sub view
    
    override func addSubviews() {
        super.addSubviews()
        self.addSubview(titleLabel)
        self.addSubview(scannerView!)
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        titleLabel.topAlignWithParent(constant: 20)
        titleLabel.applyBlockElementConstraints()
        
        scannerView?.placeBelow(toItem: titleLabel)
        scannerView?.leftAlignWithParent()
        scannerView?.rightAlignWithParent()
        scannerView?.bottomAlignWithParent()
    }
    
    
    //MARK: - QR-Code
    
    func onQRCodeDataReceived(_ data:[String]?) {
        self.qrDataString = data
    }
    
    func getpaylaodDataFromQR(_ qr: String) -> [String: Any?]? {
        if ( 0 == qr.count ) {
            return nil
        }
        
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(qr) as? [String : Any?];
        } catch {
            return nil
        }
        
        if ( nil == jsonObj) {
            return nil
        }
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = jsonObj!["dd"] as? String else {
            return nil
        }
        
        if dataDefination.caseInsensitiveCompare(getDataDefination()) != .orderedSame {
            return nil
        }
        
        guard let _ = OstUtils.toString(jsonObj!["ddv"] as Any?)?.uppercased() else {
            return nil
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            return nil
        }
        self.qrPayloadData = payloadData
        
        let payloadMeta = jsonObj!["m"] as? [String: Any?]
        self.qrMeta = payloadMeta
        
        return payloadData
    }
    
    func getDataDefination() -> String {
        return ""
    }
}
