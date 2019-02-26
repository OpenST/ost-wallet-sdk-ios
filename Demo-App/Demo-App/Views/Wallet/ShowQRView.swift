//
//  ShowQRView.swift
//  Demo-App
//
//  Created by aniket ayachit on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit
import OstSdk

class ShowQRView: BaseWalletWorkflowView {

    @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
        let currentUser = CurrentUser.getInstance();
//        OstSdk.addDevice(userId: currentUser.ostUserId!, delegate: self.sdkInteract)
        let qrCode = try! OstSdk.getAddDeviceQRCode(userId: currentUser.ostUserId!)
        let multiplyingFactor = (qrCodeImageView.frame.height/100)
        let transform: CGAffineTransform  = CGAffineTransform(scaleX: multiplyingFactor, y: multiplyingFactor);
        let output: CIImage = qrCode!.transformed(by: transform)
        qrCodeImageView.image = UIImage(ciImage: output)
        
        self.activityIndicator.stopAnimating()
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
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(qrCodeImageView)
        super.addSubViews();
        self.nextButton.setTitle("Show me QR-Code", for: .normal);
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
        constraints.append(NSLayoutConstraint(item: qrCodeImageView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: logoImageView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 22))
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
}
