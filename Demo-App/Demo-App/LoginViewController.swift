/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import OstSdk
import MaterialComponents

class LoginViewController: UIViewController {
  var isLoginMode:Bool = true;
    
  let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false;
    scrollView.backgroundColor = .white
    scrollView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    return scrollView
  }()

  let logoImageView: UIImageView = {
    let baseImage = UIImage.init(named: "ShrineLogo")
    let templatedImage = baseImage?.withRenderingMode(.alwaysTemplate)
    let logoImageView = UIImageView(image: templatedImage)
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    return logoImageView
  }()

  let titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Sign in to continue"
    titleLabel.sizeToFit()
    return titleLabel
  }()

  //Add text fields
  let usernameTextField: MDCTextField = {
    let usernameTextField = MDCTextField()
    usernameTextField.translatesAutoresizingMaskIntoConstraints = false
    usernameTextField.clearButtonMode = .unlessEditing
    return usernameTextField
  }()
  let mobileNumberTextField: MDCTextField = {
    let mobileNumberTextField = MDCTextField()
    mobileNumberTextField.translatesAutoresizingMaskIntoConstraints = false
    mobileNumberTextField.isSecureTextEntry = false
    return mobileNumberTextField
  }()

  // Add text field controllers
  let usernameTextFieldController: MDCTextInputControllerOutlined
  let mobileNumberTextFieldController: MDCTextInputControllerOutlined

  // Add buttons
  let toggleModeButton: MDCFlatButton = {
    let toggleModeButton = MDCFlatButton()
    toggleModeButton.translatesAutoresizingMaskIntoConstraints = false
    toggleModeButton.setTitle("Create Account", for: .normal)
    toggleModeButton.addTarget(self, action: #selector(didToggleMode(sender:)), for: .touchUpInside)
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


  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    //Setup text field controllers
    usernameTextFieldController = MDCTextInputControllerOutlined(textInput: usernameTextField)
    mobileNumberTextFieldController = MDCTextInputControllerOutlined(textInput: mobileNumberTextField)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.tintColor = .black
    scrollView.backgroundColor = .white

    view.addSubview(scrollView)

    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",
                                     options: [],
                                     metrics: nil,
                                     views: ["scrollView" : scrollView])
    )
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                     options: [],
                                     metrics: nil,
                                     views: ["scrollView" : scrollView])
    )
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTouch))
    scrollView.addGestureRecognizer(tapGestureRecognizer)

    scrollView.addSubview(titleLabel)
    scrollView.addSubview(logoImageView)

    // TextFields
    // Add text fields to scroll view and setup initial state
    scrollView.addSubview(usernameTextField)
    scrollView.addSubview(mobileNumberTextField)
    usernameTextFieldController.placeholderText = "Username"
    usernameTextField.delegate = self
    mobileNumberTextFieldController.placeholderText = "Mobile Number"
    mobileNumberTextField.delegate = self
    mobileNumberTextField.keyboardType = .phonePad
    registerKeyboardNotifications()

    // Buttons
    // Add buttons to the scroll view
    scrollView.addSubview(nextButton)
    scrollView.addSubview(toggleModeButton)
    
    // Error Label
    scrollView.addSubview(errorLabel);

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
    constraints.append(NSLayoutConstraint(item: usernameTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: titleLabel,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 22))
    constraints.append(NSLayoutConstraint(item: usernameTextField,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(contentsOf:
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-[username]-|",
                                     options: [],
                                     metrics: nil,
                                     views: [ "username" : usernameTextField]))
    constraints.append(NSLayoutConstraint(item: mobileNumberTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: usernameTextField,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 8))
    constraints.append(NSLayoutConstraint(item: mobileNumberTextField,
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
                                     views: [ "mobileNumber" : mobileNumberTextField]))

    // Buttons
    // Setup button constraints
    constraints.append(NSLayoutConstraint(item: toggleModeButton,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: mobileNumberTextField,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 8))
    constraints.append(NSLayoutConstraint(item: toggleModeButton,
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
                                     views: [ "cancel" : toggleModeButton, "next" : nextButton]))
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

  // MARK: - Gesture Handling

  @objc func didTapTouch(sender: UIGestureRecognizer) {
    view.endEditing(true)
  }

  // MARK: - Action Handling
  // Add the button handlers
  @objc func didTapNext(sender: Any) {
    self.errorLabel.text = "";
    if ( validateUsername() && validatePhoneNumber() ) {
      let currentUser = CurrentUser.getInstance();
      if ( isLoginMode ) {
        currentUser.login(username: usernameTextField.text!, phonenumber: mobileNumberTextField.text!) { (isLoggedIn:Bool) in
          if ( isLoggedIn ) {
            self.dismiss(animated: true, completion: nil);
            return;
          }
          self.errorLabel.text = "Invalid Credentials";
        }
      } else {
        currentUser.signUp(username: usernameTextField.text!, phonenumber: mobileNumberTextField.text!) { (isLoggedIn:Bool) in
          if ( isLoggedIn ) {
            self.dismiss(animated: true, completion: nil);
            return;
          }
          self.errorLabel.text = "Invalid Credentials";

        }
      }
    }
    return;
  }

  @objc func didToggleMode(sender: Any) {
    self.isLoginMode = !self.isLoginMode;
    if ( self.isLoginMode) {
      titleLabel.text = "Sign in to continue";
      toggleModeButton.setTitle("Create Account", for: .normal);
    } else {
      titleLabel.text = "Create your Account";
      toggleModeButton.setTitle("Sign in instead", for: .normal)
    }
    mobileNumberTextField.text = "";
    usernameTextField.text = "";
    errorLabel.text = "";
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
    self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0);
  }

  @objc func keyboardWillHide(notification: NSNotification) {
    self.scrollView.contentInset = UIEdgeInsets.zero;
  }
    
    func validateUsername() -> Bool {
        if (usernameTextField.text!.count < 4) {
            usernameTextFieldController.setErrorText("Username is too short",
                                                     errorAccessibilityValue: nil);
            return false;
        }
        usernameTextFieldController.setErrorText(nil,errorAccessibilityValue: nil);
        return true;
    }
    
    func validatePhoneNumber() -> Bool {
        if (mobileNumberTextField.text!.count < 10) {
            mobileNumberTextFieldController.setErrorText("Mobile Number is too short",
                                                         errorAccessibilityValue: nil);
            return false;
        }
        mobileNumberTextFieldController.setErrorText(nil,errorAccessibilityValue: nil);
        return true;
    }
}


// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {

  // Add basic Mobile Number field validation in the textFieldShouldReturn delegate function
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    
    // TextField
    if (textField == mobileNumberTextField && mobileNumberTextField.text != nil ) {
        _ = validatePhoneNumber();
    }

    if (textField == usernameTextField && usernameTextField.text != nil) {
        _ = validateUsername();
    }

    return false
  }
}
