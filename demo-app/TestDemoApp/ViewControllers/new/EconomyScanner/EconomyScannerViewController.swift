/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk
import AVFoundation

class EconomyScannerViewController: OstBaseViewController {
    //MAKR: - Components
    
    var titleLabel: UILabel = {
        let view = OstUIKit.h1()
        view.textAlignment = .center
        view.text = "Select your Economy"
        return view
    }()
    
    var leadLabel: UILabel = {
       let view = OstUIKit.leadLabel()
        view.textAlignment = .center
        view.text = "Scan the QR code available on the OST Platform to select your economy.  (Your app won’t require this step)"
        return view
    }()
    
    var closeButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "CloseImageBlack"), for: .normal)
        return button
    }()
    
    var bottomLabel: UILabel = {
        let view = OstUIKit.leadLabel()
        view.textColor = UIColor.white
        view.backgroundColor = UIColor.color(22, 141, 193)
        view.textAlignment = .center
        view.text = "Scanning in progress…"
        return view
    }()
    
    var scanner: OstScannerView? = nil
    
    
    //MARK: - View LC
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanner?.stopScanning()
    }
    
    //MAKR: - Add Subview
    
    override func addSubviews() {
        super.addSubviews()
        
        titleLabel.textAlignment = .center
        addScannerView()
        setupButtonAction()
        
        addSubview(titleLabel)
        addSubview(leadLabel)
        addSubview(scanner!)
        addSubview(closeButton)
        addSubview(bottomLabel)
    }
    
    func setupButtonAction() {
        closeButton.addTarget(self, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
    }

    func addScannerView() {
        let viewPreview = OstScannerView(completion: {[weak self] (values) in
            self?.scannerDataReceived(values: values)
        })
        viewPreview.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        scanner = viewPreview
    }
    
    //MARK: - Add Layout Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addTitleLabelConstrints()
        addLeadLabelConstraints()
        addScannerConstraints()
        addCloseButtonConstraints()
        addBottomLabelConstraints()
    }
    
    func addTitleLabelConstrints() {
        let guide = view.safeAreaLayoutGuide
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10).isActive = true
        titleLabel.applyBlockElementConstraints( horizontalMargin: 40)
    }
    
    func addLeadLabelConstraints() {
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints( horizontalMargin: 40)
    }
    
    func addScannerConstraints() {
        scanner?.placeBelow(toItem: leadLabel)
        scanner?.applyBlockElementConstraints(horizontalMargin: 1)
        scanner?.bottomAlign(toItem: bottomLabel)
    }
    
    func addCloseButtonConstraints() {
        let guide = view.safeAreaLayoutGuide
        closeButton.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        closeButton.leftAlignWithParent(multiplier: 1, constant: 10)
        closeButton.setFixedWidth(constant: 44)
        closeButton.setFixedHeight(multiplier: 1, constant: 44)
    }
    
    func addBottomLabelConstraints() {
        bottomLabel.bottomAlignWithParent()
        bottomLabel.applyBlockElementConstraints(horizontalMargin: 0)
        bottomLabel.setFixedHeight(constant: 65)
    }
    
    func scannerDataReceived(values: [String]?) {
        if (nil != values) && !values!.isEmpty {
            guard let qrData = values!.first,
                    let qrJsonData = EconomyScannerViewController.getQRJsonData(qrData) else {
                scanner?.startScanning()
                return
            }
            CurrentEconomy.getInstance.economyDetails = qrJsonData as [String : Any]
            
            self.dismiss(animated: true, completion: nil)
        }else {
            scanner?.startScanning()
        }
    }
    
    class func getQRJsonData(_ qr: String) -> [String: Any?]? {
        let jsonObj: [String:Any?]?
        do {
            jsonObj = try OstUtils.toJSONObject(qr) as? [String : Any?]
        } catch {
            return nil
        }
        
        let viewEndPoint = jsonObj!["view_api_endpoint"] as? String
        let tokenId = jsonObj!["token_id"]
        let mappyApiEndpoint = jsonObj!["mappy_api_endpoint"]
        let tokenSymbol = jsonObj!["token_symbol"]
        
        if nil == viewEndPoint || nil == tokenId || nil == mappyApiEndpoint || nil == tokenSymbol {
            return nil
        }
        
        UserDefaults.standard.set(qr, forKey: CurrentEconomy.userDefaultsId)
        UserDefaults.standard.synchronize()

        return jsonObj
    }
    
    @objc func closeButtonTapped(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
