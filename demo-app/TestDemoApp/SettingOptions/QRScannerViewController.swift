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
    
    //MARK: - View LC
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanner?.startScanning()
    }
    
    //MAKR: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        addScannerView()
    }
    
    func addScannerView() {
        let viewPreview = OstScannerView(completion: {[weak self] (values) in
            guard let strongSelf = self else {return}
            if (nil != values) && !values!.isEmpty {
                guard let qrData = values!.first else {
                    strongSelf.scanner?.startScanning()
                    return
                }
                
                let currentUser = CurrentUser.getInstance();
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
        
        let lastView = scanner!
        lastView.bottomAlignWithParent()
    }
    
    func addViewPreviewConstraints() {
        scanner?.placeBelow(toItem: leadLabel)
        scanner?.setW375Width(width: 375)
        scanner?.setAspectRatio(width: 375, height: 493)
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
