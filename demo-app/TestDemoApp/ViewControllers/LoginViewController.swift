/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk
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

  let bioTextField: MDCTextField = {
    let bioTextField = MDCTextField()
    bioTextField.translatesAutoresizingMaskIntoConstraints = false
    bioTextField.isSecureTextEntry = false
    bioTextField.isHidden = true;
    return bioTextField
  }()

  
  // Add text field controllers
  let usernameTextFieldController: MDCTextInputControllerOutlined
  let mobileNumberTextFieldController: MDCTextInputControllerOutlined
  let bioTextFieldController: MDCTextInputControllerOutlined

  // Add buttons
  let toggleModeButton: MDCButton = {
    let toggleModeButton = MDCButton()
    toggleModeButton.translatesAutoresizingMaskIntoConstraints = false
    toggleModeButton.setTitle("Create Account", for: .normal)
    toggleModeButton.addTarget(self, action: #selector(didToggleMode(sender:)), for: .touchUpInside)
    return toggleModeButton
  }()
  let nextButton: MDCButton = {
    let nextButton = MDCButton()
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
  
  let logoImageView: UIImageView = {
    let baseImage = UIImage.init(named: "Logo")
    let logoImageView = UIImageView(image: baseImage);
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    return logoImageView
  }()


  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    //Setup text field controllers
    usernameTextFieldController = MDCTextInputControllerOutlined(textInput: usernameTextField)
    mobileNumberTextFieldController = MDCTextInputControllerOutlined(textInput: mobileNumberTextField)
    bioTextFieldController = MDCTextInputControllerOutlined(textInput: bioTextField);
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
    

    // TextFields
    // Add text fields to scroll view and setup initial state
    scrollView.addSubview(usernameTextField)
    scrollView.addSubview(mobileNumberTextField)
    scrollView.addSubview(bioTextField)
    
    usernameTextFieldController.placeholderText = "Username"
    usernameTextField.delegate = self
    
    mobileNumberTextFieldController.placeholderText = "Mobile Number"
    mobileNumberTextField.delegate = self
    mobileNumberTextField.keyboardType = .phonePad
    
    bioTextFieldController.placeholderText = "Description"
    bioTextField.delegate = self;
    
    registerKeyboardNotifications()

    // Buttons
    // Add buttons to the scroll view
    scrollView.addSubview(activityIndicator)
    scrollView.addSubview(nextButton)
    scrollView.addSubview(toggleModeButton)
    scrollView.sendSubviewToBack(self.activityIndicator);
    
    
    // Error Label
    scrollView.addSubview(errorLabel);
    
    // Logo
    scrollView.addSubview(logoImageView)

    // Constraints
    var constraints = [NSLayoutConstraint]()
    
    constraints.append(NSLayoutConstraint(item: logoImageView,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    
    constraints.append(NSLayoutConstraint(item: logoImageView,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: scrollView.contentLayoutGuide,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: 49))
    
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
    
    constraints.append(NSLayoutConstraint(item: bioTextField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: mobileNumberTextField,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 8))
    constraints.append(NSLayoutConstraint(item: bioTextField,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    constraints.append(contentsOf:
      NSLayoutConstraint.constraints(withVisualFormat: "H:|-[bioTextField]-|",
                                     options: [],
                                     metrics: nil,
                                     views: [ "bioTextField" : bioTextField]))

    // Buttons
    // Setup button constraints
    
    constraints.append(NSLayoutConstraint(item: toggleModeButton,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: bioTextField,
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
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: 50))
    constraints.append(NSLayoutConstraint(item: nextButton,
                                          attribute: .width,
                                          relatedBy: .greaterThanOrEqual,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: 90))
    
    
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
    
    constraints.append(NSLayoutConstraint(item: errorLabel,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: scrollView.contentLayoutGuide,
                                          attribute: .bottomMargin,
                                          multiplier: 1,
                                          constant: -20))

    
    NSLayoutConstraint.activate(constraints)
    
    let appScheme = ApplicationScheme.shared;
    MDCContainedButtonThemer.applyScheme(appScheme.buttonScheme, to: nextButton);
    MDCTextButtonThemer.applyScheme(appScheme.buttonScheme, to: toggleModeButton);
    
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
      var gotSuccessCallback = false;
      
      //Define onSuccessCallback
      let onSuccessCallback: ((OstUser, OstDevice) -> Void) = { ostUser, userDevice in
        gotSuccessCallback = true
        if ( ostUser.isStatusCreated ) {
          //Need to activate user.
          let rootViewController =  self.presentingViewController;
          self.dismiss(animated: true, completion: {
            let setupWalletController = WalletViewController(nibName: nil, bundle: nil)
            setupWalletController.showHeaderBackItem = false;
            rootViewController?.present(setupWalletController, animated: true, completion: nil);
          });
          
        } else if ( ostUser.isStatusActivating ) {
          //User is still activating.
          self.dismiss(animated: true, completion: nil);
        } else if ( ostUser.isStatusActivated ) {
          //User is already activated. Lets check if we need to authorize the device.
          self.dismiss(animated: true, completion: nil);
        }
      }
      
      //Define onCompleteCallback.
      let onCompleteCallback: ((Bool) -> Void) = { isLoggedIn in
        if ( !isLoggedIn ) {
          self.errorLabel.text = "Invalid Credentials";
        } else if ( !gotSuccessCallback ) {
          self.errorLabel.text = "Failed to register device. Please retry.";
        }
        self.activityIndicator.stopAnimating();
        self.toggleModeButton.isHidden = false;
        self.nextButton.isHidden = false;
      }
      
      self.activityIndicator.center = nextButton.center;
      self.toggleModeButton.isHidden = true;
      self.nextButton.isHidden = true;
      self.activityIndicator.startAnimating();
      
      if ( isLoginMode ) {
        currentUser.login(username: usernameTextField.text!,
                          phonenumber:  mobileNumberTextField.text!,
                          onSuccess: onSuccessCallback,
                          onComplete: onCompleteCallback)
      } else {
        var userDescription = bioTextField.text
        if ( nil == userDescription || userDescription!.count < 1 ) {
          userDescription = "Hey there! I am using Ost powered token economy."
        }
        
        currentUser.signUp(username: usernameTextField.text!,
                           phonenumber: mobileNumberTextField.text!,
                           userDescription: userDescription!,
                           onSuccess: onSuccessCallback,
                           onComplete: onCompleteCallback);
      }
    }
    return;
  }

  @objc func didToggleMode(sender: Any) {
    
    self.isLoginMode = !self.isLoginMode;
    if ( self.isLoginMode) {
      
      titleLabel.text = "Sign in to continue";
      toggleModeButton.setTitle("Create Account", for: .normal);
      bioTextField.isHidden = true;
    } else {
      titleLabel.text = "Create your Account";
      toggleModeButton.setTitle("Sign in instead", for: .normal)
      bioTextField.isHidden = false;
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
