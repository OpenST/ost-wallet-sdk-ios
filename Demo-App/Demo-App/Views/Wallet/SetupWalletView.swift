//
//  SetupWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents

class SetupWalletView: UIScrollView {
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
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
  
  let activityIndicator: MDCActivityIndicator = {
    let activityIndicator = MDCActivityIndicator()
    activityIndicator.indicatorMode = .indeterminate
    activityIndicator.sizeToFit()
    //#e4b030
    let color1 = UIColor.init(red: 228.0/255.0, green: 176.0/255.0, blue: 48.0/255.0, alpha: 1.0);
    //#438bad
    let color2 = UIColor.init(red: 67.0/255.0, green: 139.0/255.0, blue: 173.0/255.0, alpha: 1.0);
    //#34445b
    let color3 = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    //#27b8d2
    let color4 = UIColor.init(red: 39.0/255.0, green: 184.0/255.0, blue: 210.0/255.0, alpha: 1.0);
    activityIndicator.cycleColors = [color1, color2, color3, color4]
    return activityIndicator;
  }()
  
  //Add text fields
  let pinNumberTextField: MDCTextField = {
    let mobileNumberTextField = MDCTextField()
    mobileNumberTextField.translatesAutoresizingMaskIntoConstraints = false
    mobileNumberTextField.isSecureTextEntry = false
    return mobileNumberTextField
  }()
  
  // Add text field controllers
  let pinNumberTextFieldController: MDCTextInputControllerOutlined
  
  // Add buttons
  let doItLaterButton: MDCFlatButton = {
    let toggleModeButton = MDCFlatButton()
    toggleModeButton.translatesAutoresizingMaskIntoConstraints = false
    toggleModeButton.setTitle("Do it later", for: .normal)
    toggleModeButton.addTarget(self, action: #selector(didCancelAction(sender:)), for: .touchUpInside)
    return toggleModeButton
  }()
  let nextButton: MDCRaisedButton = {
    let nextButton = MDCRaisedButton()
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    nextButton.setTitle("NEXT", for: .normal)
    nextButton.addTarget(self, action: #selector(didTapNext(sender:)), for: .touchUpInside)
    return nextButton
  }()
  
  let errorLabel: UILabel = {
    let errorLabel = UILabel()
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.text = ""
    errorLabel.textColor = UIColor.red;
    errorLabel.sizeToFit()
    return errorLabel
  }()
  
  override init(frame: CGRect) {
    //Setup text field controllers
    pinNumberTextFieldController = MDCTextInputControllerOutlined(textInput: pinNumberTextField)
    super.init(frame: frame);
    self.addSubViews();
    self.addSubviewConstraints();
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addSubViews() {
    let scrollView = self;
    
    scrollView.addSubview(titleLabel)
    scrollView.addSubview(logoImageView)
    
    // TextFields
    // Add text fields to scroll view and setup initial state
    scrollView.addSubview(pinNumberTextField)
    
    pinNumberTextFieldController.placeholderText = "6 Digit Pin"
    pinNumberTextField.delegate = self
    pinNumberTextField.keyboardType = .numberPad
    
    
    registerKeyboardNotifications()
    
    // Buttons
    // Add buttons to the scroll view
    scrollView.addSubview(nextButton)
    scrollView.addSubview(doItLaterButton)
    scrollView.addSubview(activityIndicator)
    
    // Error Label
    scrollView.addSubview(errorLabel);
    
  }
  
  func addSubviewConstraints() {
    let scrollView = self;
    
    // Constraints
    var constraints = [NSLayoutConstraint]()
    constraints.append(NSLayoutConstraint(item: logoImageView,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: scrollView.contentLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 49))
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
    
    // Buttons
    // Setup button constraints
    constraints.append(NSLayoutConstraint(item: doItLaterButton,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: pinNumberTextField,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 8))
    constraints.append(NSLayoutConstraint(item: doItLaterButton,
                                          attribute: .centerY,
                                          relatedBy: .equal,
                                          toItem: nextButton,
                                          attribute: .centerY,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(contentsOf:
      NSLayoutConstraint.constraints(withVisualFormat: "H:[cancel]-[next]-|",
                                     options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                     metrics: nil,
                                     views: [ "cancel" : doItLaterButton, "next" : nextButton]))
    constraints.append(NSLayoutConstraint(item: nextButton,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: scrollView.contentLayoutGuide,
                                          attribute: .bottomMargin,
                                          multiplier: 1,
                                          constant: -20))
    
    // Error Label
    constraints.append(NSLayoutConstraint(item: errorLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: nextButton,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 22))
    constraints.append(NSLayoutConstraint(item: errorLabel,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    
    NSLayoutConstraint.activate(constraints)
  }

  
  
  // MARK: - Action Handling
  // Add the button handlers
  @objc func didTapNext(sender: Any) {
    if ( !validatePinNumber() ) {
      return;
    }
  }
  
  @objc func didCancelAction(sender: Any) {
    //Canceled the action.
    
  }
  
  // MARK: - Keyboard Handling
  
  func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillShow),
      name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"),
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillShow),
      name: NSNotification.Name(rawValue: "UIKeyboardWillChangeFrameNotification"),
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWillHide),
      name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"),
      object: nil)
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame =
      (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0);
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    self.contentInset = UIEdgeInsets.zero;
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
