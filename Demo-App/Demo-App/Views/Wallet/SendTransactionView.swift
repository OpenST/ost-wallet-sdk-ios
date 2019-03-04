//
//  SendTransaction.swift
//  Demo-App
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
import AVFoundation

class SendTransactionView: BaseWalletWorkflowView, AVCaptureMetadataOutputObjectsDelegate {
    
    @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
//        startReading()
        
        let qrCode: [String: Any] = ["dd": "transaction",
                                     "ddv": "1.1.0",
                                     "d":["rn": "Direct Transfer",
                                        "ads": ["0x69dde10524bb360df6167d2d7ce8fe8b9092abd2"],
                                        "ams": ["4"],
                                        "tid": "1036"]
        ]

        let qrCodeString = try! OstUtils.toJSONString(qrCode)
        sendTransaction(qrCodeString: qrCodeString!)
        
        
        
//        //Resetpin
//        let currentUser = CurrentUser.getInstance()
//        OstSdk.resetPin(userId: currentUser.ostUserId!,
//                        password: currentUser.userPinSalt!,
//                        oldPin: "123458",
//                        newPin: "123459",
//                        delegate: self.sdkInteract)
    }
    
    func sendTransaction(qrCodeString: String) {
        let currentUser = CurrentUser.getInstance();
        OstSdk.perfrom(userId: currentUser.ostUserId!,
                       payload: qrCodeString,
                       delegate: self.sdkInteract)
    }
    
    var captureSession: AVCaptureSession? = nil
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    
    // Mark - Sub Views
    let logoImageView: UIImageView = {
        let baseImage = UIImage.init(named: "Logo")
        let logoImageView = UIImageView(image: baseImage);
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    let viewPreview: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.layer.cornerRadius = 10
        viewPreview.layer.borderColor = UIColor.gray.cgColor
        viewPreview.layer.borderWidth = 2
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        return viewPreview
    }()
    
    override func addSubViews() {
        let scrollView = self;
        
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(viewPreview)
        
        super.addSubViews();
        self.nextButton.setTitle("StartReading", for: .normal);
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView.contentLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: viewPreview,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: logoImageView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 12))
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
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 200))
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[viewPreview]-|",
                                           options: [],
                                           metrics: nil,
                                           views: [ "viewPreview" : viewPreview]))
        
        NSLayoutConstraint.activate(constraints)
        super.addBottomSubviewConstraints(afterView:viewPreview);
    }
    
    
    func startReading() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
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
    
    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer!.removeFromSuperlayer()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        let qrCode = (videoPreviewLayer?.transformedMetadataObject(for: metadataObjects[0]) as? AVMetadataMachineReadableCodeObject)?.stringValue
        if (qrCode == nil) {
            self.nextButton.isHidden = false
        }else {
            self.sendTransaction(qrCodeString: qrCode!)
        }
    }

}
