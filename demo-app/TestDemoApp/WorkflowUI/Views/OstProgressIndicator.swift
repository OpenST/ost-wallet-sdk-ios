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
    var progressText: String = ""
    {
        didSet {
            alert?.title = "\n\(progressText)"
        }
    }
    
    var progressMessage: String = ""
    {
        didSet {
            alert?.message = progressMessage
        }
    }
    
    var textCode: OstProgressIndicatorTextCode! {
        didSet {
            progressText = textCode.rawValue
        }
    }
    
    //MARK: - Initializier
    init(progressText: String = "") {
        self.progressText = progressText
        super.init(frame: .zero)
    }
    
    init(textCode: OstProgressIndicatorTextCode) {
        self.progressText = textCode.rawValue
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        progressText = ""
        super.init(coder: aDecoder)
    }
    
    //MAKR: - Create Views
    override func createViews() {
        super.createViews()
        //        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        //        self.addSubview(containerView)
        //
        //        containerView.addSubview(activityIndicator)
        //        containerView.addSubview(progressTextLabel)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        //        applyContainerViewConstraints()
        //        applyActivityIndicatorConstraints()
        //        applyTextLabelConstraints()
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
    
    var alert: UIAlertController? = nil
    func show() {
        
        let title = "\n\(progressText)"
        alert = UIAlertController(title: title,
                                  message: "",
                                  preferredStyle: .alert)
        
        let activ = UIActivityIndicatorView(style: .gray)
        activ.startAnimating()
        activ.translatesAutoresizingMaskIntoConstraints = false
        alert!.view.addSubview(activ)
        activ.centerXAnchor.constraint(equalTo: alert!.view.centerXAnchor).isActive = true
        activ.topAnchor.constraint(equalTo: alert!.view.topAnchor, constant: 10).isActive = true
        
        alert?.show()
        
        //        guard let parent = self.superview else {return}
        
        //        parent.bringSubviewToFront(self)
        //        self.frame = parent.bounds
        //        activityIndicator.startAnimating()
        //        self.backgroundColor = UIColor.white
        //        self.alpha = 1.0
        //        self.containerView.alpha = 1.0
        //        UIView.animate(withDuration: 0.4) {
        //            self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        //        }
        //
        //        let theAnimation: CABasicAnimation
        //        theAnimation = CABasicAnimation(keyPath: "transform.scale")
        //        theAnimation.duration = 0.4;
        //        theAnimation.repeatCount = 1;
        //        theAnimation.autoreverses = false;
        //        theAnimation.fromValue = 1.1
        //        theAnimation.toValue = 1
        //        theAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        //        self.containerView.layer.add(theAnimation, forKey: "animateOpacity")
    }
    
    @objc func hide(onCompletion: ((Bool) -> Void)? = nil) {
        
        if nil == alert {
            onCompletion?(true)
        }else {
            alert!.dismiss(animated: true, completion: {
                onCompletion?(true)
            })
        }
        
        //        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        //        UIView.animate(withDuration: 0.4, animations: {[weak self] in
        //            self?.backgroundColor = .white
        //            self?.containerView.alpha = 0.0
        //        }) {[weak self] (isComplete) in
        //            self?.removeFromSuperview()
        //            onCompletion?(isComplete)
        //        }
        
    }
    
    func showSuccessAlert(withTitle title: String = "", message msg: String = "",  onCompletion:((Bool) -> Void)? = nil) {
        
        self.hide {[weak self] _ in
            self?.alert = UIAlertController(title: """
                
                
                
                \(title)
                """,
                message: msg,
                preferredStyle: .alert)
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "transactionCheckmark")
            
            self?.alert?.view.addSubview(imageView)
            
            let parent = imageView.superview!
            imageView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 28).isActive = true
            imageView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
            self?.alert?.show()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                 self?.hide(onCompletion: onCompletion)
            })
        }
    }
    
    func showFailureAlert(withTitle title: String = "", message msg: String = "", onCompletion:((Bool) -> Void)? = nil) {
        
        self.hide {[weak self] _ in
            self?.alert = UIAlertController(title: """
                
                
                
                \(title)
                """,
                message: msg,
                preferredStyle: .alert)
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "transactionCheckmark")
            
            self?.alert?.view.addSubview(imageView)
            
            let parent = imageView.superview!
            imageView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 28).isActive = true
            imageView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
            self?.alert?.show()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.hide(onCompletion: onCompletion)
            })
        }
    }
}

enum OstProgressIndicatorTextCode: String {
    case
    unknown = "Processing...",
    activingUser = "Activiting User...",
    executingTransaction = "Executing transaction...",
    fetchingUser = "Fetching user...",
    stopDeviceRecovery = "Stoping device recovery...",
    initiateDeviceRecovery = "Initiating device recovery...",
    logoutUser = "Logging out...",
    signup = "Siging up...",
    login = "Logging in...",
    resetPin = "Reseting pin...",
    checkDeviceStatus = "Checking device status…",
    fetchingUserBalance = "Fetching user balance..."
}
