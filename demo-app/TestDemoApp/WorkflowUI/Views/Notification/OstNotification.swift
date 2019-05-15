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
       let label = OstUIKit.leadLabel()
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
    
    //MARK: - Add Subview
    override func createViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = getContainerBackgorundColor()
        imageView.image = getImage()
        addShadow()
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        addSubview(containerView)
        
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
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
        containerView.bottomAlign(toItem: titleLabel, constant: 10)
    }
    
    func applyTitleLabelConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 10)
        titleLabel.leftWithRightAlign(toItem: imageView, constant:8)
        titleLabel.rightAlignWithParent(multiplier: 1, constant: -8)
    }
    
    func applyImageViewConstraints() {
        imageView.topAlignWithParent(multiplier: 1, constant: 10)
        imageView.leftAlignWithParent(multiplier: 1, constant: 10)
        imageView.setFixedWidth(constant: 24)
        imageView.setFixedHeight(multiplier: 1, constant: 24)
    }
    
    //MARK: - Show Hide View
    func show(onCompletion: ((Bool) -> Void)? = nil) {
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
    
    var notificationModel: OstNotificationModel! {
        didSet {
            self.titleLabel.text = getTitle()
        }
    }
    
    func getTitle() -> String {
        let workflowContext = notificationModel.workflowContext
        var titleText = ""
        
        if let contextEntity = notificationModel.contextEntity {
            
            if workflowContext.workflowType == .addSession {
                titleText = getAddSessionText(contextEntity: contextEntity)
            }
            
            
            
            
            
            
            
        }else if let error = notificationModel.error {
            titleText = error.errorMessage
        }
        
        return titleText
    }
    
    func getAddSessionText(contextEntity: OstContextEntity) -> String {
        var titleText = "Session created successfully."
        if let entity: OstSession = contextEntity.entity as? OstSession {
            let aproxExpirationTime = entity.approxExpirationTimestamp
            if aproxExpirationTime > 0 {
                let date = Date(timeIntervalSince1970:aproxExpirationTime)
                titleText += "It expires approximately on \(date.getDateString())"
            }
        }

        return titleText
    }
}
