//
//  UserDetailsView.swift
//  Demo-App
//
//  Created by aniket ayachit on 27/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class UserDetailsView: BaseWalletWorkflowView {

    var viewPreview: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.layer.cornerRadius = 10
        viewPreview.layer.borderColor = UIColor.gray.cgColor
        viewPreview.layer.borderWidth = 2
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        return viewPreview
    }();
    
    var qrInfoLabel: QRInfoLabel = {
        let qrInfoLabel = QRInfoLabel()
        qrInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        qrInfoLabel.text = "";
        return qrInfoLabel;
    }();
    
    override func addSubViews() {
        let scrollView = self;
        scrollView.addSubview(qrInfoLabel)
        scrollView.addSubview(viewPreview)
        super.addSubViews();
        self.nextButton.isHidden = true
        self.cancelButton.isHidden = true
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
    
    override func viewDidAppearCallback() {
        super.viewDidAppearCallback();
        self.qrInfoLabel.showUserInfo()
    }

    
}
