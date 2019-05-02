//
//  ScannerView.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import AVFoundation

class OstScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
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
   
    
    init(completion: (([String]?) -> Void)?) {
        self.onCompletion = completion
        super.init(frame: .zero)
        createViews()
        applyConstraints()
    }
    
    deinit {
        print("deinit: \(String(describing: self))")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
        applyConstraints()

    }
    
    private func createViews() {
        self.addSubview(scannerContainer)
    }
    
    private func applyConstraints() {
        guard let parent = scannerContainer.superview else {return}
        scannerContainer.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        scannerContainer.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        scannerContainer.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        scannerContainer.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    private func addCaptureSession() {
        
        if nil == captureSession {
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
        }
        
        if nil == videoPreviewLayer {
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
    }
    
    //MARK: - Methods
    func startScanning() {
        addCaptureSession()
        captureSession?.startRunning()
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
