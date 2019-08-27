//
//  ScannerView.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
    }
    
    override func applyConstraints() {
        guard let parent = scannerContainer.superview else {return}
        scannerContainer.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        scannerContainer.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        scannerContainer.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        scannerContainer.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
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
        } catch let error as NSError {
            // Handle any errors
            print(error)
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

            AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] (granted: Bool) in
                DispatchQueue.main.async {
                    if granted {
                        self?.addCaptureSession()
                        self?.captureSession?.startRunning()
                        self?.cameraPermissionState?(.authorized)
                        
                    } else {
                        self?.showAlertForAccessDenied()
                        self?.cameraPermissionState?(.denied)
                    }
                }
            })
    }
    
    func showAlertForAccessDenied() {
        let alert = UIAlertController(title: "Access Denied",
                                      message: "Camera permission has been denied. Please grant access to scan QR-Code from device settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
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
