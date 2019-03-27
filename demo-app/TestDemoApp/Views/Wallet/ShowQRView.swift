/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class ShowQRView: BaseWalletWorkflowView {

    @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
        self.activityIndicator.startAnimating();
        let currentUser:OstUser = CurrentUser.getInstance().ostUser!;
        self.logsTextView.text = "";
        self.errorLabel.text = "";
        self.successLabel.text = "";
        self.nextButton.isHidden = true;
        OstWalletSdk.setupDevice(userId: currentUser.id,
                                 tokenId: currentUser.tokenId!,
                                 delegate: self.sdkInteract);
    }
    
    override func receivedSdkEvent(eventData: [String : Any]) {
        super.receivedSdkEvent(eventData: eventData);
        let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
        if ( OstSdkInteract.WorkflowEventType.flowComplete == eventType
            || OstSdkInteract.WorkflowEventType.flowInterrupt == eventType) {
            
            let workflowContext: OstWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext
            if ( workflowContext.workflowType != OstWorkflowType.setupDevice ) {
                return;
            }
            
            if (OstSdkInteract.WorkflowEventType.flowInterrupt == eventType) {
                //Failed to update status.
                self.errorLabel.text = "Failed to update status.";
                self.successLabel.text = "";
                return;
            }
            
            let ostContextEntity: OstContextEntity = eventData["ostContextEntity"] as! OstContextEntity
            self.activityIndicator.stopAnimating()
            let userDevice = ostContextEntity.entity as! OstDevice;
            if ( userDevice.isStatusAuthorized ) {
                self.successLabel.text = "Device has been authorized.";
                self.errorLabel.text = "";
            } else {
                self.successLabel.text = "";
                if ( userDevice.isStatusRegistered ) {
                    self.errorLabel.text = "Device is 'Registered'.";
                } else if ( userDevice.isStatusCreated ) {
                    self.errorLabel.text = "Device is 'Created'.";
                } else if ( userDevice.isStatusAuthorizing ) {
                    self.errorLabel.text = "Device is still Authorizing.";
                }
            }
        }
        self.nextButton.isHidden = false;
        self.cancelButton.isHidden = true;
        self.activityIndicator.stopAnimating();
    }
    
    // Mark - Sub Views
    let logoImageView: UIImageView = {
        let baseImage = UIImage.init(named: "Logo")
        let logoImageView = UIImageView(image: baseImage);
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    // Mark - Sub Views
    var qrCodeImageView: UIImageView = {
        var qrCodeImageView = UIImageView(image: nil)
        qrCodeImageView.backgroundColor = UIColor.lightGray
        qrCodeImageView.layer.borderWidth = 1
        qrCodeImageView.layer.cornerRadius = 5
        qrCodeImageView.layer.borderColor = UIColor.lightGray.cgColor
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        return qrCodeImageView
    }()
    
    override func addSubViews() {
        let scrollView = self;
        
        scrollView.addSubview(qrCodeImageView)
        super.addSubViews();
        self.nextButton.setTitle("Check Authorization", for: .normal);
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView.contentLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 90))
        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: qrCodeImageView,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 40))
        
        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: -40))
        
        NSLayoutConstraint.activate(constraints)
        super.addBottomSubviewConstraints(afterView:qrCodeImageView);
    }
    
    override func viewDidAppearCallback() {
        super.viewDidAppearCallback();
        let currentUser = CurrentUser.getInstance();
        //        OstWalletSdk.addDevice(userId: currentUser.ostUserId!, delegate: self.sdkInteract)
        do {
            guard let qrCode = try OstWalletSdk.getAddDeviceQRCode(userId: currentUser.ostUserId!) else {
                return
            }
            let multiplyingFactor = (qrCodeImageView.frame.height/100)
            let transform: CGAffineTransform  = CGAffineTransform(scaleX: multiplyingFactor, y: multiplyingFactor);
            let output: CIImage = qrCode.transformed(by: transform)
            qrCodeImageView.image = UIImage(ciImage: output)
        }catch let error {
            addToLog(log: (error as! OstError).errorMessage)
            return
        }
        
       
    }
}
