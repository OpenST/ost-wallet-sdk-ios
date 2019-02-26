//
//  PaperWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
class PaperWalletView: BaseWalletWorkflowView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  @objc override func didTapNext(sender: Any) {
    super.didTapNext(sender: sender);
    let currentUser = CurrentUser.getInstance();
    OstSdk.getPaperWallet(userId: currentUser.ostUserId!, delegate: self.sdkInteract);
  }
  // Mark - Sub Views
  let logoImageView: UIImageView = {
    let baseImage = UIImage.init(named: "Logo")
    let logoImageView = UIImageView(image: baseImage);
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    return logoImageView
  }()
  
  let wordsTextView: UITextView = {
    let wordsTextView = UITextView()
    wordsTextView.translatesAutoresizingMaskIntoConstraints = false
    wordsTextView.text = "****** ****** ****** "
        + "****** ****** ****** "
        + "****** ****** ****** "
        + "****** ****** ******"
    ;
    wordsTextView.textAlignment = NSTextAlignment.center
    wordsTextView.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    wordsTextView.textColor = UIColor.white;
    wordsTextView.layer.cornerRadius = 8;
    wordsTextView.layer.borderColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0).cgColor;
    wordsTextView.isEditable = false;
    wordsTextView.font = UIFont.systemFont(ofSize: 20);
    return wordsTextView
  }()
  
  override func addSubViews() {
    let scrollView = self;
    scrollView.addSubview(self.logoImageView)
    scrollView.addSubview(self.wordsTextView)
    super.addSubViews();
    self.nextButton.setTitle("Show me the words", for: .normal);
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
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .height,
                                          multiplier: 0.25,
                                          constant: 0))
    
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
    
    super.addBottomSubviewConstraints(afterView:wordsTextView, constraints: constraints);
  }
  
  override func receivedSdkEvent(eventData: [String : Any]) {
    super.receivedSdkEvent(eventData: eventData);
    let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
    if ( OstSdkInteract.WorkflowEventType.showPaperWallet != eventType ) {
      return;
    }
    
    guard let mnemonics:[String] = eventData["mnemonics"] as? [String] else {
        return;
    }
    let wordsToShow:String = mnemonics.joined(separator: " ");
    self.wordsTextView.text = wordsToShow;
    self.nextButton.isHidden = true;
    self.cancelButton.isHidden = true;
    self.activityIndicator.stopAnimating();
  }
}
