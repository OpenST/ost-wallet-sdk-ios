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
    
    
    //MARK: - View LC
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                
                let currentUser = CurrentUserModel.getInstance
                OstWalletSdk.performQRAction(userId: currentUser.ostUserId!,
                                             payload: qrData,
                                             delegate: strongSelf.workflowDelegate)
            }else {
                strongSelf.scanner?.startScanning()
            }
        })
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        scanner = viewPreview
        addSubview(scanner!)
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
    
    //MARK: - OstWalletSdk Workflow delegate
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId, workflowContext: workflowContext, error: error)
        scanner?.startScanning()
    }
}
