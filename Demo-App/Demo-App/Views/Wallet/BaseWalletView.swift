//
//  BaseWalletView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class BaseWalletView: UIScrollView {
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */

  
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
  
  func addSubViews() {
    registerKeyboardNotifications()
  }
}
