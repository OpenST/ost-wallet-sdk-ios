//
//  PaperWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
import MaterialComponents
class AddDeviceWithMnemonics: BaseWalletWorkflowView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }7387858886
    */
  @objc override func didTapNext(sender: Any) {
    
    if self.nextButton.titleLabel?.text == "VERIFIED" {
        self.ostValidateDataProtocol!.dataVerified()
        self.activityIndicator.startAnimating()
        self.nextButton.isHidden = true
    }else {
        super.didTapNext(sender: sender);
        let currentUser = CurrentUser.getInstance();
        let mnemonics = wordsTextView.text!.components(separatedBy: " ")
        OstSdk.addDeviceWithMnemonics(userId: currentUser.ostUserId!,
                                      mnemonics: mnemonics,
                                      delegate: self.sdkInteract)
    }
  }
  // Mark - Sub Views
  let logoImageView: UIImageView = {
    let baseImage = UIImage.init(named: "Logo")
    let logoImageView = UIImageView(image: baseImage);
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    return logoImageView
  }()
  
  let wordsTextView: MDCMultilineTextField = {
    let wordsTextView = MDCMultilineTextField()
    wordsTextView.translatesAutoresizingMaskIntoConstraints = false
    wordsTextView.isEnabled = true;
    wordsTextView.minimumLines = 3;
    return wordsTextView
  }()
    var wordsTextController:MDCTextInputControllerOutlinedTextArea? = nil;
    
    let viewPreview: UIView = {
        var viewPreview = UIView(frame: CGRect.zero)
        viewPreview.backgroundColor = UIColor.clear
        viewPreview.layer.cornerRadius = 10
        viewPreview.layer.borderColor = UIColor.gray.cgColor
        viewPreview.layer.borderWidth = 2
        viewPreview.translatesAutoresizingMaskIntoConstraints = false
        viewPreview.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
        return viewPreview
    }();
    let qrInfoLabel: QRInfoLabel = {
        let qrInfoLabel = QRInfoLabel()
        qrInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        qrInfoLabel.text = "";
        qrInfoLabel.numberOfLines = 0
        qrInfoLabel.textColor = UIColor.white
        return qrInfoLabel;
    }();

  override func addSubViews() {
    let scrollView = self;
    self.wordsTextController = MDCTextInputControllerOutlinedTextArea(textInput: wordsTextView);
    self.wordsTextController?.placeholderText = "Paper Wallet Words"
    
    scrollView.addSubview(self.logoImageView)
    scrollView.addSubview(self.wordsTextView)
    scrollView.addSubview(self.viewPreview);
    self.viewPreview.addSubview(qrInfoLabel)
    self.viewPreview.isHidden = true
    scrollView.sendSubviewToBack(self.viewPreview)
    super.addSubViews();
    self.nextButton.setTitle("Authorize", for: .normal);
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
    constraints.append(NSLayoutConstraint(item: wordsTextView,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: logoImageView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 20))
    
    constraints.append(NSLayoutConstraint(item: wordsTextView,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .leading,
                                          multiplier: 1,
                                          constant: 10))

    constraints.append(NSLayoutConstraint(item: wordsTextView,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .trailing,
                                          multiplier: 1,
                                          constant: -10))
    
    let vpConst = CGFloat(10.0);
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
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: wordsTextView,
                                          attribute: .bottom,
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
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: viewPreview,
                                          attribute: .trailing,
                                          multiplier: 1,
                                          constant: -10))
    constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: viewPreview,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: viewPreview,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(NSLayoutConstraint(item: self.qrInfoLabel,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: viewPreview,
                                          attribute: .leading,
                                          multiplier: 1,
                                          constant: 10))
    
    super.addBottomSubviewConstraints(afterView:wordsTextView, constraints: constraints);
  }
  
    var ostValidateDataProtocol:OstValidateDataProtocol?
  override func receivedSdkEvent(eventData: [String : Any]) {
    super.receivedSdkEvent(eventData: eventData);
    let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
    if ( OstSdkInteract.WorkflowEventType.verifyQRCodeData != eventType ) {
      return;
    }
    
    guard let contextEntity: OstContextEntity = eventData["ostContextEntity"] as? OstContextEntity else {
        return;
    }
    ostValidateDataProtocol = eventData["delegate"] as! OstValidateDataProtocol
    let device: OstCurrentDevice = contextEntity.entity as! OstCurrentDevice
    viewPreview.isHidden = false
    let scrollView = self;
    scrollView.bringSubviewToFront(viewPreview)
    qrInfoLabel.text = "Device to add: \(device.address!)"
    
    nextButton.setTitle("VERIFIED", for: .normal)
    self.nextButton.isHidden = false;
    self.cancelButton.isHidden = true;
    self.activityIndicator.stopAnimating();
  }
}
