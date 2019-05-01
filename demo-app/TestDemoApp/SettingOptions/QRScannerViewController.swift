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
    var captureSession: AVCaptureSession? = nil
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    let viewPreview: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        return viewPreview
    }();
    
    override func getNavBarTitle() -> String {
        return "Scan QR"
    }
    override func getLeadLabelText() -> String {
        return "Scan the QR code to procced"
    }
    
    //MARK: - View LC
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startReading()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    //MAKR: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        addSubview(viewPreview)
    }
    
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addViewPreviewConstraints()
        
        let lastView = viewPreview
        lastView.bottomAlignWithParent()
    }
    
    func addViewPreviewConstraints() {
        viewPreview.placeBelow(toItem: leadLabel)
        viewPreview.setW375Width(width: 375)
        viewPreview.setAspectRatio(width: 375, height: 493)
    }
    
    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func startReading() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        if (captureDevice == nil) {
            
            let alert = UIAlertController(title: "Please check camera permission.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil) )
            self.present(alert, animated: true, completion: nil)
    
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer!.frame = viewPreview.layer.bounds
        viewPreview.layer.addSublayer(videoPreviewLayer!)
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        print(captureMetadataOutput.availableMetadataObjectTypes)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        let qrCode = (videoPreviewLayer?.transformedMetadataObject(for: metadataObjects[0]) as? AVMetadataMachineReadableCodeObject)?.stringValue
        
        if (nil == qrCode) {
            return;
        }
        let currentUser = CurrentUser.getInstance();
        OstWalletSdk.performQRAction(userId: currentUser.ostUserId!,
                                     payload: qrCode!,
                                     delegate: self.workflowDelegate)
        
        //Stop using cam.
        stopReading();
    }
    
    //MARK: - OstWalletSdk Workflow delegate
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId, workflowContext: workflowContext, error: error)
        
        startReading()
    }
}
