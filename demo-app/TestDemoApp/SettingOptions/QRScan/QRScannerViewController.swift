//
//  QRScannerViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import AVFoundation
import OstWalletSdk


class QRScannerViewController: BaseSettingOptionsViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - Components
    var scanner: OstScannerView? = nil
    
    override func getNavBarTitle() -> String {
        return "Scan QR"
    }
    override func getLeadLabelText() -> String {
        return "Scan the QR code to procced"
    }
    
    var bottomLabel: UILabel = {
        let view = OstUIKit.leadLabel()
        view.textColor = UIColor.white
        view.backgroundColor = UIColor.color(22, 141, 193)
        view.textAlignment = .center
        view.text = "Scanning in progress…"
        return view
    }()
    
    weak var tabBarVC: TabBarViewController? = nil
    
    //MARK: - View LC
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanner?.cameraPermissionState = {[weak self] state in
            if state == AVAuthorizationStatus.denied {
                self?.bottomLabel.text = "Access denied"
            }
            else if state == AVAuthorizationStatus.authorized {
                self?.bottomLabel.text = "Scanning in progress…"
            }
            else {
                self?.bottomLabel.text = ""
            }
        }
        scanner?.startScanning()
    }
    
    //MAKR: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        addScannerView()
        addSubview(bottomLabel)
    }
    
    func addScannerView() {
        let viewPreview = OstScannerView(completion: {[weak self] (values) in
            guard let strongSelf = self else {return}
            if (nil != values) && !values!.isEmpty {
                guard let qrData = values!.first else {
                    strongSelf.scanner?.startScanning()
                    return
                }
                strongSelf.scannedQRData(qrData)
            }else {
                strongSelf.scanner?.startScanning()
            }
        })
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        scanner = viewPreview
        addSubview(scanner!)
    }
    
    func scannedQRData(_ qrData: String) {
        scanner?.stopScanning()
        showProgressIndicator()
        let currentUser = CurrentUserModel.getInstance
        OstWalletSdk.performQRAction(userId: currentUser.ostUserId!,
                                     payload: qrData,
                                     delegate: workflowDelegate)
    }
    
    func showProgressIndicator() {
        
    }
    
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addViewPreviewConstraints()
        addBottomLabelConstraints()
    }
    
    func addViewPreviewConstraints() {
        scanner?.placeBelow(toItem: leadLabel)
        scanner?.applyBlockElementConstraints(horizontalMargin: 0)
        scanner?.bottomFromTopAlign(toItem: bottomLabel)
    }
    
    func addBottomLabelConstraints() {
        bottomLabel.bottomAlignWithParent()
        bottomLabel.applyBlockElementConstraints(horizontalMargin: 0)
        bottomLabel.setFixedHeight(constant: 65)
    }

    //MARK: - QR-Code
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
        
        if dataDefination.caseInsensitiveCompare(validDataDefination()) != .orderedSame {
            return nil
        }
        
        guard let _ = ConversionHelper.toString(jsonObj!["ddv"] as Any?)?.uppercased() else {
            return nil
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            return nil
        }
        
        return payloadData
    }
    
    func validDataDefination() -> String {
        return ""
    }
    
}
