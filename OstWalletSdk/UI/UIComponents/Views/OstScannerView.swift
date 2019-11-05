/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

import UIKit
import AVFoundation

class OstScannerView: OstBaseView, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - Components
    private let scannerContainer: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        return viewPreview
    }();
    
    //MARK: - Variables
    private var onCompletion: (([String]?) -> Void)?
    private var captureSession: AVCaptureSession? = nil
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    
    var cameraPermissionState: ((AVAuthorizationStatus) -> Void)? = nil
    
    init(completion: (([String]?) -> Void)?) {
        self.onCompletion = completion
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func createViews() {
        self.addSubview(scannerContainer)
        
        backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func applyConstraints() {
        scannerContainer.topAlignWithParent()
        scannerContainer.leftAlignWithParent()
        scannerContainer.rightAlignWithParent()
        scannerContainer.bottomAlignWithParent()
    }
    
    private func addCaptureSession() {
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        if (captureDevice == nil) {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error  {
            // Handle any errors
            Logger.log(message: "error while setting AVCaptureDeviceInput", parameterToPrint: error)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer!.frame = scannerContainer.layer.bounds
        scannerContainer.layer.addSublayer(videoPreviewLayer!)
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    //MARK: - Methods
    func startScanning() {
        if nil == OstBundle.getApplictionInfoPlistContent(for: "NSCameraUsageDescription") {
            
            self.showAlert(title: "Missing Permission",
                           message: "Camera usage description is missing from 'Info.plist'. Please add description for 'NSCameraUsageDescription' to use QR-Scanning functionality.")
        }else {
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] (granted: Bool) in
                DispatchQueue.main.async {
                    if granted {
                        self?.addCaptureSession()
                        self?.captureSession?.startRunning()
                        self?.cameraPermissionState?(.authorized)
                        
                    } else {
                        self?.showAlert(title: "Access Denied",
                                        message: "Camera permission has been denied. Please grant access to scan QR-Code from device settings.")
                        self?.cameraPermissionState?(.denied)
                    }
                }
            })
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = OstUIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.show()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning();
        
        var qrData = [String]()
        for metadataObject in metadataObjects {
            if let dataString = (videoPreviewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject)?.stringValue {
                qrData.append(dataString)
            }
        }
        onCompletion?(qrData)
    }
    
}
