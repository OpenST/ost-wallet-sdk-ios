//
//  AddDeviceFromQRCode.swift
//  Demo-App
//
//  Created by aniket ayachit on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
import AVFoundation
import MaterialComponents

class ScanQRCodeView: BaseWalletWorkflowView, AVCaptureMetadataOutputObjectsDelegate {
    // Mark - QR code scan methods.
    func startReading() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        if (captureDevice == nil) {
            
            let alert = UIAlertController(title: "Please check camera permission.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil) )
            self.walletViewController?.present(alert, animated: true, completion: nil)
            
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
        
        //Update UI.
        self.nextButton.isHidden = true;
        self.cancelButton.isHidden = true;
        self.scanAgainButton.isHidden = true;
        self.qrInfoLabel.isHidden = true;
        self.viewPreview.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    }
    
    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        let qrCode = (videoPreviewLayer?.transformedMetadataObject(for: metadataObjects[0]) as? AVMetadataMachineReadableCodeObject)?.stringValue
        
        if (nil == qrCode) {
            showInvalidQRCode();
            return;
        }
        let currentUser = CurrentUser.getInstance();
        OstSdk.perfrom(userId: currentUser.ostUserId!,
                       payload: qrCode!,
                       delegate: self.sdkInteract)
        
        //Stop using cam.
        stopReading();
        
    }
    
    // Mark - Sdk Interact methods.
    @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
        self.ostValidateDataProtocol?.dataVerified();
    }
    
    func executeQRCodeInfo(qrCodeString: String) {
        let currentUser = CurrentUser.getInstance();
        OstSdk.perfrom(userId: currentUser.ostUserId!,
                       payload: qrCodeString,
                       delegate: self.sdkInteract)
    }
    
    var captureSession: AVCaptureSession? = nil
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    
    let viewPreview: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.layer.cornerRadius = 10
        viewPreview.layer.borderColor = UIColor.gray.cgColor
        viewPreview.layer.borderWidth = 2
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        return viewPreview
    }();
    
    let scanAgainButton: MDCRaisedButton = {
        let scanAgainButton = MDCRaisedButton()
        scanAgainButton.translatesAutoresizingMaskIntoConstraints = false
        scanAgainButton.setTitle("Scan Again", for: .normal)
        scanAgainButton.addTarget(self, action: #selector(didTapScanAgain(sender:)), for: .touchUpInside)
        return scanAgainButton;
    }();
    
    let qrInfoLabel: QRInfoLabel = {
        let qrInfoLabel = QRInfoLabel()
        qrInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        qrInfoLabel.text = "";
        return qrInfoLabel;
    }();
    
    
    
    override func addSubViews() {
        let scrollView = self;
        
        scrollView.addSubview(viewPreview);
        scrollView.addSubview(scanAgainButton);
        scrollView.addSubview(qrInfoLabel);
        
        super.addSubViews();
        self.nextButton.setTitle("Authorize", for: .normal);
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()
        
        let vpConst = CGFloat(5.0);
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView.contentLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 120))
        
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: viewPreview,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: vpConst))
        
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: -vpConst))
        
        constraints.append(NSLayoutConstraint(item: self.scanAgainButton,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: self.nextButton,
                                              attribute: .left,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: self.scanAgainButton,
                                              attribute: .right,
                                              relatedBy: .equal,
                                              toItem: self.nextButton,
                                              attribute: .right,
                                              multiplier: 1,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: self.scanAgainButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.nextButton,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: self.scanAgainButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.nextButton,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: self.viewPreview,
                                              attribute: .left,
                                              multiplier: 1,
                                              constant: 10))
        
        constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                              attribute: .right,
                                              relatedBy: .equal,
                                              toItem: self.viewPreview,
                                              attribute: .right,
                                              multiplier: 1,
                                              constant: -10))
        constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.viewPreview,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 10))
        
        
        super.addBottomSubviewConstraints(afterView:viewPreview, constraints:constraints);
    }
    
    
    
    
    
    
    func showTransactionData(qrData:[String:Any?]) {
        //To-Do: Implement this.
    }
    
    func showInvalidQRCode() {
        showScanAgain();
        self.qrInfoLabel.isHidden = false;
        self.qrInfoLabel.text = "Invalid QR Code. Please try again.";
    }
    
    func showAuthorizeDeviceInfo(ostDevice:OstDevice) {
        self.nextButton.isHidden = false;
        self.cancelButton.isHidden = false;
        self.scanAgainButton.isHidden = true;
        self.qrInfoLabel.isHidden = false;
        self.qrInfoLabel.showDeviceInfo(ostDevice: ostDevice);
    }
    
    func showScanAgain() {
        self.nextButton.isHidden = true;
        self.cancelButton.isHidden = true;
        self.scanAgainButton.isHidden = false;
    }
    
    
    override func viewDidDisappearCallback() {
        super.viewDidDisappearCallback();
        stopReading();
    }
    
    override func viewDidAppearCallback() {
        super.viewDidAppearCallback();
        startReading();
    }
    
    var ostValidateDataProtocol:OstValidateDataProtocol?;
    
    override func receivedSdkEvent(eventData: [String : Any]) {
        let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
        if (.flowInterrupt == eventType ) {
            let interuptedWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext;
            if ( interuptedWorkflowContext.workflowType == .scanQRCode ) {
                //Show invalid QR Code.
                showInvalidQRCode();
                
                // Done.
                return;
            } else if ( interuptedWorkflowContext.workflowType == .addDeviceWithQRCode ) {
                // Forward it to base class.
                super.receivedSdkEvent(eventData: eventData);
                
                //Update UI
                showScanAgain();
                
                // Done.
                return;
            }
            else {
                // Forward it to base class.
                super.receivedSdkEvent(eventData: eventData);
                return;
            }
        }
        else if (.flowComplete == eventType ) {
            let completedWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext;
            if ( completedWorkflowContext.workflowType == .scanQRCode
                || completedWorkflowContext.workflowType == .addDeviceWithQRCode) {
                
                // Forward it to base class.
                super.receivedSdkEvent(eventData: eventData);
                
                //Update UI
                showScanAgain();
                
                // Done.
                return;
                
            } else {
                // Forward it to base class.
                super.receivedSdkEvent(eventData: eventData);
                return;
            }
        }
        else if (OstSdkInteract.WorkflowEventType.verifyQRCodeData != eventType ) {
            // Forward it to base class.
            return super.receivedSdkEvent(eventData: eventData);
        }
        
        
        let workflowContext = eventData["workflowContext"] as! OstWorkflowContext;
        let ostContextEntity = eventData["ostContextEntity"] as! OstContextEntity;
        self.ostValidateDataProtocol = eventData["delegate"] as? OstValidateDataProtocol;
        if ( workflowContext.workflowType == .addDeviceWithQRCode ) {
            let device = ostContextEntity.entity as! OstDevice;
            showAuthorizeDeviceInfo(ostDevice: device);
        } else if ( workflowContext.workflowType == .executeTransaction ) {
            //To-Do: Show transaction info.
        }
    }
    
    @objc func didTapScanAgain(sender: Any) {
        // Lets Reset UI.
        self.errorLabel.text = "";
        self.successLabel.text = "";
        self.qrInfoLabel.isHidden = true;
        
        // Hide Action Buttons and start indicator.
        startReading();
    }
}