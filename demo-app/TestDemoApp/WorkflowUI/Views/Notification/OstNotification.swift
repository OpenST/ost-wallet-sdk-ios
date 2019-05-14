/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class OstNotification: OstBaseView {
    
    //MARK: - Components
    let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleLabel: UILabel = {
       let label = OstUIKit.leadLabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "Aniket"
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
        
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        containerView.backgroundColor = getContainerBackgorundColor()
        imageView.image = getImage()
        addShadow()
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        addSubview(containerView)
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
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
    
    //MARK: - Variables
    var topAnchorConstraint: NSLayoutConstraint? = nil
    
    var title: String! {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    func show() {
        applySelfConstraints()
       
        self.layoutIfNeeded()
        
        topAnchorConstraint?.constant = 10
        self.containerView.alpha = 0.3
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 1
            self.layoutIfNeeded()
        }) { (isComplete) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {[weak self] in
                self?.hide()
            })
        }
    }
    
    func hide() {
        topAnchorConstraint?.constant = -100
        self.containerView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0.0
            self.layoutIfNeeded()
        }) {[weak self] (isComplete) in
           self?.removeFromSuperview()
        }
        
    }
}
