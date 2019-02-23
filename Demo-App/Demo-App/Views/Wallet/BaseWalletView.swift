//
//  BaseWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents

class BaseWalletView: UIScrollView {
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */

  override init(frame: CGRect) {
    super.init(frame: frame);
    self.addSubViews();
    self.addSubviewConstraints();
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Mark - WalletViewController interacting methods.
  
  public weak var walletViewController: WalletViewController?
  
  func dismissViewController() {
    walletViewController?.dismiss(animated: true, completion: nil);
  }

  func dismissViewController(completion: @escaping (() -> Void)) {
    walletViewController?.dismiss(animated: true, completion: completion);
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
  
  func addSubviewConstraints() {
    //To-Be Overridden.
  }
  
  func addSubViews() {
    registerKeyboardNotifications()
    let scrollView = self;
    // Buttons
    // Add buttons to the scroll view
    scrollView.addSubview(nextButton)
    scrollView.addSubview(cancelButton)
    scrollView.addSubview(activityIndicator)
    
    // Labels
    scrollView.addSubview(errorLabel);
    scrollView.addSubview(successLabel);
    scrollView.addSubview(logsLabel);
    
  }
  
  func addBottomSubviewConstraints(afterView:UIView) {
    let scrollView = self;
    // Buttons
    // Setup button constraints
    var constraints = [NSLayoutConstraint]()
    constraints.append(NSLayoutConstraint(item: nextButton,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: afterView,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 8))
    constraints.append(NSLayoutConstraint(item: cancelButton,
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
                                     views: [ "cancel" : cancelButton, "next" : nextButton]))
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
    
    constraints.append(NSLayoutConstraint(item: successLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: errorLabel,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 0))
    
    constraints.append(NSLayoutConstraint(item: successLabel,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    
    constraints.append(NSLayoutConstraint(item: logsLabel,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: successLabel,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 0))
    
    constraints.append(NSLayoutConstraint(item: logsLabel,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: scrollView,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0))
    
    constraints.append(NSLayoutConstraint(item: logsLabel,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: scrollView.contentLayoutGuide,
                                          attribute: .bottomMargin,
                                          multiplier: 1,
                                          constant: -20))
    NSLayoutConstraint.activate(constraints)
    
    let appScheme = ApplicationScheme.shared;
    MDCContainedButtonThemer.applyScheme(appScheme.buttonScheme, to: nextButton);
    MDCTextButtonThemer.applyScheme(appScheme.buttonScheme, to: cancelButton);
    
  }
  
  // Add buttons
  let nextButton: MDCRaisedButton = {
    let nextButton = MDCRaisedButton()
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    nextButton.setTitle("NEXT", for: .normal)
    nextButton.addTarget(self, action: #selector(didTapNext(sender:)), for: .touchUpInside)
    return nextButton
  }()
  
  let cancelButton: MDCButton = {
    let toggleModeButton = MDCButton()
    toggleModeButton.translatesAutoresizingMaskIntoConstraints = false
    toggleModeButton.setTitle("Do it later", for: .normal)
    toggleModeButton.addTarget(self, action: #selector(didCancelAction(sender:)), for: .touchUpInside)
    return toggleModeButton
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
  
  // Add Labels.
  let errorLabel: UILabel = {
    let errorLabel = UILabel()
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.text = ""
    errorLabel.textColor = UIColor.red;
    errorLabel.sizeToFit()
    return errorLabel
  }()
  
  let successLabel: UILabel = {
    let successLabel = UILabel()
    successLabel.translatesAutoresizingMaskIntoConstraints = false
    successLabel.text = ""
    successLabel.textColor = UIColor.init(red: 67.0/255.0, green: 139.0/255.0, blue: 173.0/255.0, alpha: 1.0);
    successLabel.sizeToFit()
    return successLabel
  }()
  
  let logsLabel: UILabel = {
    let logsLabel = UILabel()
    logsLabel.translatesAutoresizingMaskIntoConstraints = false
    logsLabel.text = ""
    logsLabel.textColor = UIColor.lightGray;
    logsLabel.sizeToFit()
    logsLabel.numberOfLines = 0;
    return logsLabel
  }()
  
  // MARK: - Action Handling
  
  @objc func didCancelAction(sender: Any) {
    //Canceled the action.
    self.dismissViewController();
  }
  
  @objc func didTapNext(sender: Any) {
    // Lets Reset UI.
    self.errorLabel.text = "";
    self.successLabel.text = "";
    
    // Hide Action Buttons and start indicator.
    self.nextButton.isHidden = true;
    self.cancelButton.isHidden = true;
    self.activityIndicator.center = self.nextButton.center;
    self.activityIndicator.startAnimating();
  }
  
}
