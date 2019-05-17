/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class OstNotification: OstBaseView {
    
    func getAppWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    //MARK: - Components
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = OstFontProvider().get(size: 14).bold()
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var actionButton: UIButton = {
        let button = OstButton()
        button.translatesAutoresizingMaskIntoConstraints = false
       
        let buttonThemer = OstTheme.linkButton
        buttonThemer.fontProvider = OstFontProvider()
        buttonThemer.borderColor = UIColor.clear.cgColor
        buttonThemer.titleFontSize = 14
        buttonThemer.setTitleColor(color: UIColor.white, state: .normal)
        
        let clearBgImg = UIImage.withColor(1, 1, 1, 0);
        buttonThemer.setBackgroundImage(image: clearBgImg, state: .highlighted);
        buttonThemer.setBackgroundImage(image: clearBgImg, state: .normal);
        
        buttonThemer.apply(button)
        
        return button
    }()
    
    //MARK: - Add Subview
    override func createViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = getContainerBackgorundColor()
        imageView.image = getImage()
        addShadow()
        
        actionButton.addTarget(self, action: #selector(self.actionButtonTapped(_ :)), for: .touchUpInside)
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(actionButton)
        addSubview(containerView)
    
        addTapGesture()
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureDetected))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapGestureDetected() {
        OstNotificationManager.getInstance.removeNotification()
    }

    func addShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10
    }
    
    //MAKR: - Components Settings
    func getContainerBackgorundColor() -> UIColor {
        return .lightGray
    }
    
    func getImage() -> UIImage? {
        return nil
    }
    
    //MARK: - Add Constraints
    
    override func applyConstraints() {
        applyContainerViewConstraints()
        applyTitleLabelConstraints()
        applyImageViewConstraints()
        applyActionButtonConstraints()
    }
    
    func applySelfConstraints() {
        self.topAlignWithParent()
        self.applyBlockElementConstraints(horizontalMargin: 0)
        self.bottomAlign(toItem: containerView)
    }
    
    func applyContainerViewConstraints() {
        topAnchorConstraint = containerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: -100)
        topAnchorConstraint!.isActive = true
        containerView.leftAlignWithParent(multiplier: 1, constant: 10)
        containerView.rightAlignWithParent(multiplier: 1, constant: -10)
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45).isActive = true
        containerView.bottomAlign(toItem: actionButton, constant: 10)
    }
    
    func applyTitleLabelConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 10)
        titleLabel.leftWithRightAlign(toItem: imageView, constant:10)
        titleLabel.rightAlignWithParent(multiplier: 1, constant: -10)
    }
    
    func applyImageViewConstraints() {
        imageView.topAlignWithParent(multiplier: 1, constant: 10)
        imageView.leftAlignWithParent(multiplier: 1, constant: 10)
        imageView.setFixedWidth(constant: 25)
        imageView.setFixedHeight(multiplier: 1, constant: 25)
    }
    
    func applyActionButtonConstraints() {
        actionButton.placeBelow(toItem: titleLabel)
        actionButton.leftAlign(toItem: titleLabel)
    }
    
    
    //MARK: - Show Hide View
    func show(onCompletion: ((Bool) -> Void)? = nil) {
        guard let window = getAppWindow() else {
            onCompletion?(false)
            return
        }
        window.addSubview(self)
        
        applySelfConstraints()
        
        self.layoutIfNeeded()
        
        topAnchorConstraint?.constant = 10
        self.containerView.alpha = 0.3
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 1
            self.layoutIfNeeded()
        }) { (isComplete) in
            onCompletion?(isComplete)
        }
    }
    
    func hide(onCompletion: ((Bool) -> Void)? = nil) {
        topAnchorConstraint?.constant = -100
        self.containerView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0.0
            self.layoutIfNeeded()
        }) {[weak self] (isComplete) in
            self?.removeFromSuperview()
            onCompletion?(isComplete)
        }
    }
    
    //MARK: - Variables
    var topAnchorConstraint: NSLayoutConstraint? = nil
    
    var message: String! {
        didSet {
            self.titleLabel.text = message
        }
    }
    
    var notificationModel: OstNotificationModel! {
        didSet {
            self.titleLabel.text = getTitle()
            self.actionButton.setTitle(getActionButtonTitle(), for: .normal)
        }
    }
    
    func getTitle() -> String {
        let workflowContext = notificationModel.workflowContext
        var titleText = ""
        
        if workflowContext.workflowType == .addSession {
            titleText = getAddSessionText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .resetPin {
            titleText = getResetPinText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .activateUser {
            titleText = getActivateUserText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .abortDeviceRecovery {
            titleText = getAbortDeviceRecoveryText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .authorizeDeviceWithMnemonics {
            titleText = getAuthorizeDeviceWithMnemonicsText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .authorizeDeviceWithQRCode {
            titleText = getAuthorizeDeviceWithQRText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        else if workflowContext.workflowType == .executeTransaction {
            titleText = getExecuteTransactionText(contextEntity: notificationModel.contextEntity, error: notificationModel.error)
        }
        return titleText
    }
    
    func getActionButtonTitle() -> String {
        return ""
    }
    
    //MARK: - Notification Text
    
    func getActivateUserText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getAddSessionText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getResetPinText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getAbortDeviceRecoveryText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getAuthorizeDeviceWithMnemonicsText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getAuthorizeDeviceWithQRText(contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    func getExecuteTransactionText (contextEntity: OstContextEntity? = nil, error: OstError? = nil) -> String {
        return ""
    }
    
    //MAKR: - Actions
    @objc func actionButtonTapped(_ sender: Any?) {
    }
}
