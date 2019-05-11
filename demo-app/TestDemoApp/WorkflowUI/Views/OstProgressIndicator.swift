//
//  OstProgressIndicator.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstProgressIndicator: OstBaseView {
    
    //MARK: - Components
    let containerView: UIView  = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    let progressTextLabel: UILabel =  OstUIKit.leadLabel()
    
    //MARK: - Variables
    var progressText: String! {
        didSet {
            progressTextLabel.text = progressText
        }
    }
    
    //MARK: - Initializier
    init(progressText: String = "") {
        progressTextLabel.text = progressText
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        progressTextLabel.text = ""
        super.init(coder: aDecoder)
    }
    
    //MAKR: - Create Views
    override func createViews() {
        super.createViews()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.addSubview(containerView)
        
        containerView.addSubview(activityIndicator)
        containerView.addSubview(progressTextLabel)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        applyContainerViewConstraints()
        applyActivityIndicatorConstraints()
        applyTextLabelConstraints()
    }
    
    func applyContainerViewConstraints() {
        containerView.centerYAlignWithParent()
        containerView.applyBlockElementConstraints()
    }
    
    func applyActivityIndicatorConstraints() {
        activityIndicator.centerXAlignWithParent()
        activityIndicator.topAlignWithParent(multiplier: 1, constant: 20)
    }
    
    func applyTextLabelConstraints() {
        progressTextLabel.placeBelow(toItem: activityIndicator)
        progressTextLabel.applyBlockElementConstraints()
        progressTextLabel.bottomAlignWithParent(constant: -20)
    }
    
    func show() {
        guard let paretn = self.superview else {return}
        
        paretn.bringSubviewToFront(self)
        self.frame = paretn.bounds
        activityIndicator.startAnimating()
        self.backgroundColor = UIColor.white
        UIView.animate(withDuration: 0.4) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        
        let theAnimation: CABasicAnimation
        theAnimation = CABasicAnimation(keyPath: "transform.scale")
        theAnimation.duration = 0.4;
        theAnimation.repeatCount = 1;
        theAnimation.autoreverses = false;
        theAnimation.fromValue = 1.1
        theAnimation.toValue = 1
        theAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        self.containerView.layer.add(theAnimation, forKey: "animateOpacity")
    }
    
    func hide() {
        self.alpha = 0.0
        self.removeFromSuperview()
    }
}
