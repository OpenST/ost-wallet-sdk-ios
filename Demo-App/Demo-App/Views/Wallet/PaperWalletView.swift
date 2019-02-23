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
  
  let wordsLabel: UILabel = {
    let wordsLabel = UILabel()
    wordsLabel.translatesAutoresizingMaskIntoConstraints = false
    wordsLabel.text = "\n\n\n\n" + "****** ****** ******" + "\n\n" + "****** ****** ******" + "\n\n" + "****** ****** ******" + "\n\n" + "****** ****** ******" + "\n\n\n\n";
    wordsLabel.textAlignment = NSTextAlignment.center
    wordsLabel.numberOfLines = 0;
    wordsLabel.backgroundColor = UIColor.init(red: 231.0/255.0, green: 246.0/255.0, blue: 247.0/255.0, alpha: 1.0);
    wordsLabel.layer.cornerRadius = 8;
    wordsLabel.layer.borderColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0).cgColor;
    
    return wordsLabel
  }()
  
  override func addSubViews() {
    let scrollView = self;
    scrollView.addSubview(logoImageView)
    scrollView.addSubview(wordsLabel)
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
    constraints.append(NSLayoutConstraint(item: wordsLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: logoImageView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 22))
    constraints.append(NSLayoutConstraint(item: wordsLabel,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))

    constraints.append(NSLayoutConstraint(item: wordsLabel,
                                          attribute: .height,
                                          relatedBy: .greaterThanOrEqual,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 0.35,
                                          constant: scrollView.frame.height))
    
    constraints.append(NSLayoutConstraint(item: wordsLabel,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .leading,
                                          multiplier: 1,
                                          constant: 10))

    constraints.append(NSLayoutConstraint(item: wordsLabel,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .trailing,
                                          multiplier: 1,
                                          constant: -10))
    
    NSLayoutConstraint.activate(constraints)
    super.addBottomSubviewConstraints(afterView:wordsLabel);
  }
  
  override func receivedSdkEvent(eventData: [String : Any]) {
    super.receivedSdkEvent(eventData: eventData);
    let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
    if ( OstSdkInteract.WorkflowEventType.flowComplete != eventType ) {
      return;
    }
    let ostContextEntity:OstContextEntity = eventData["ostContextEntity"] as! OstContextEntity;
    if (ostContextEntity.type != OstWorkflowType.papaerWallet ) {
      return;
    }
    
    let allWords:String = ostContextEntity.entity as! String;
    var mnemonics:[String] = allWords.components(separatedBy: " ");
    var wordsToShow = "\n\n";
    for cnt in 0..<mnemonics.count {
      if ( cnt % 3 == 0 ) {
        wordsToShow = wordsToShow + "\n\n";
      }
      wordsToShow = wordsToShow + "    " + mnemonics[cnt];
    }
    wordsToShow = wordsToShow + "\n\n\n\n";
    self.wordsLabel.text = wordsToShow;
    self.nextButton.isHidden = true;
    self.cancelButton.isHidden = true;
  }
}
