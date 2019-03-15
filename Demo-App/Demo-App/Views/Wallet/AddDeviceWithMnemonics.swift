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
    }
    */
  @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
        let currentUser = CurrentUser.getInstance();
        let mnemonics = wordsTextView.text!.components(separatedBy: " ")
        OstSdk.addDeviceUsingMnemonics(userId: currentUser.ostUserId!,
                                      mnemonics: mnemonics,
                                      delegate: self.sdkInteract)
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
    
  override func addSubViews() {
    let scrollView = self;
    self.wordsTextController = MDCTextInputControllerOutlinedTextArea(textInput: wordsTextView);
    self.wordsTextController?.placeholderText = "Paper Wallet Words"
    
    scrollView.addSubview(self.logoImageView)
    scrollView.addSubview(self.wordsTextView)
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
    super.addBottomSubviewConstraints(afterView:wordsTextView, constraints: constraints);
  }
}
