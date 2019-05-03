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
    
    //MARK: - Themer
    var progressTextLabelThemer: OstLabelTheamer = OstTheme.leadLabel
    
    //MARK: - Variables
    let progressText: String
    
    //MARK: - Initializier
    init(progressText: String = "") {
        self.progressText = progressText
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.progressText = ""
        super.init(coder: aDecoder)
    }
    
    //MAKR: - Create Views
    override func createViews() {
        super.createViews()
        self.alpha = 0.0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.addSubview(containerView)
        
        containerView.addSubview(activityIndicator)
        containerView.addSubview(progressTextLabel)
       
        progressTextLabel.text = progressText
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
        if nil != self.superview {
            self.superview?.bringSubviewToFront(self)
            let screenFrame = UIScreen.main.bounds
            self.frame = screenFrame
            activityIndicator.startAnimating()
            self.alpha = 1.0
        }
    }
    
    func close() {
        self.superview?.sendSubviewToBack(self)
        self.alpha = 0.0
    }
}
