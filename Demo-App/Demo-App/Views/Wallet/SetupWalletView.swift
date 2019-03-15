//
//  SetupWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents
import OstSdk

class SetupWalletView: BaseWalletWorkflowView {
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
  // MARK: - Action Handling
  // Add the button handlers
  @objc override func didTapNext(sender: Any) {
    if ( !validatePinNumber() ) {
      return;
    }
    
    let currentUser = CurrentUser.getInstance();
    
    // Always convert the token into Wei Untis.
    let spendingLimitInWei = String( "1000000000000000000000000" )
    //Logger.log(message: "spendingLimitInWei", parameterToPrint: spendingLimitInWei);
    
    OstSdk.activateUser(userId: currentUser.ostUserId!,
                        userPin: pinNumberTextField.text!,
                        passphrasePrefix: currentUser.userPinSalt!,
                        spendingLimitInWei: spendingLimitInWei,
                        expireAfterInSec: TimeInterval(Double(2*60*60)),
                        delegate: self.sdkInteract);
    
    //Call super to update UI and log stuff.
    super.didTapNext(sender: sender);
  }
  

  
  // Mark - Sub Views
  let logoImageView: UIImageView = {
    let baseImage = UIImage.init(named: "Logo")
    let logoImageView = UIImageView(image: baseImage);
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    return logoImageView
  }()
  
  let titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Welcome to OST Powered Token Economy"
      + "\n"
      + "\n" + "Let's setup your wallet."
      + "\n" + "Enter 6 digit pin to secure your wallet"
    titleLabel.textAlignment = NSTextAlignment.center
    titleLabel.numberOfLines = 4;
    titleLabel.sizeToFit()
    return titleLabel
  }()
  

  
  //Add text fields
  let pinNumberTextField: MDCTextField = {
    let pinNumberTextField = MDCTextField()
    pinNumberTextField.translatesAutoresizingMaskIntoConstraints = false
    pinNumberTextField.isSecureTextEntry = true
    return pinNumberTextField
  }()
  
  // Add text field controllers
  let pinNumberTextFieldController: MDCTextInputControllerOutlined
      
  override init(frame: CGRect) {
    //Setup text field controllers
    pinNumberTextFieldController = MDCTextInputControllerOutlined(textInput: pinNumberTextField)
    super.init(frame: frame);
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func addSubViews() {
    super.addSubViews();
    let scrollView = self;
    
    scrollView.addSubview(titleLabel)
    scrollView.addSubview(logoImageView)
    
    // TextFields
    // Add text fields to scroll view and setup initial state
    scrollView.addSubview(pinNumberTextField)
    
    pinNumberTextFieldController.placeholderText = "6 Digit Pin"
    pinNumberTextField.delegate = self
    pinNumberTextField.keyboardType = .numberPad
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
                                          constant: 60))
    constraints.append(NSLayoutConstraint(item: logoImageView,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(NSLayoutConstraint(item: titleLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: logoImageView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 22))
    constraints.append(NSLayoutConstraint(item: titleLabel,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    // Text Fields
    // Setup text field constraints
    constraints.append(NSLayoutConstraint(item: pinNumberTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: titleLabel,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 22))
    constraints.append(NSLayoutConstraint(item: pinNumberTextField,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(contentsOf:
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mobileNumber]-|",
                                     options: [],
                                     metrics: nil,
                                     views: [ "mobileNumber" : pinNumberTextField]))
    NSLayoutConstraint.activate(constraints)
    super.addBottomSubviewConstraints(afterView:pinNumberTextField);
  }
    
  func validatePinNumber() -> Bool {
    if (pinNumberTextField.text!.count < 6) {
      pinNumberTextFieldController.setErrorText("Pin should be atleast 6 digit",
                                                errorAccessibilityValue: nil);
      return false;
    }
    pinNumberTextFieldController.setErrorText(nil,errorAccessibilityValue: nil);
    return true;
  }
  
  override func receivedSdkEvent(eventData: [String : Any]) {
    super.receivedSdkEvent(eventData: eventData);
    let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
    if ( OstSdkInteract.WorkflowEventType.flowComplete == eventType ) {
      //Time and close.
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
        self.dismissViewController();
      }
      self.addToLog(log: "This window will close in 5 seconds");
    } else if (OstSdkInteract.WorkflowEventType.flowInterrupt == eventType ) {
      self.nextButton.setTitle("Try Again", for: .normal);
    }
  }

}

// MARK: - UITextFieldDelegate
extension SetupWalletView: UITextFieldDelegate {
  
  // Add basic Mobile Number field validation in the textFieldShouldReturn delegate function
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    
    // TextField
    if (textField == pinNumberTextField && pinNumberTextField.text != nil ) {
      _ = validatePinNumber();
    }
    
    return false
  }
}
