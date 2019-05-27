//
//  OstProgressIndicator.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class OstProgressIndicator: OstBaseView {
    
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
    
    var alert: UIAlertController? = nil
    
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
    
    //MARK: - Inporgress Alert
    func show() {
        
        let title = "\n\(progressText)"
        alert = UIAlertController(title: title,
                                  message: "",
                                  preferredStyle: .alert)
        
        let activ = UIActivityIndicatorView(style: .gray)
        activ.color = UIColor.color(22, 141, 193)
        activ.startAnimating()
        activ.translatesAutoresizingMaskIntoConstraints = false
        alert!.view.addSubview(activ)
        activ.centerXAnchor.constraint(equalTo: alert!.view.centerXAnchor).isActive = true
        activ.topAnchor.constraint(equalTo: alert!.view.topAnchor, constant: 10).isActive = true
        
        alert?.show()
    }
    
    @objc func hide(onCompletion: ((Bool) -> Void)? = nil) {
        
        if nil == alert {
            onCompletion?(true)
        }else {
            alert!.dismiss(animated: true, completion: {
                onCompletion?(true)
            })
        }
    }
    
    //MARK: - Success Alert
    func showSuccessAlert(forWorkflowType type: OstWorkflowType, onCompletion:((Bool) -> Void)? = nil) {
        let title = getWorkflowCompleteText(workflowType: type)
        showSuccessAlert(withTitle: title, onCompletion: onCompletion)
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
    
    //MARK: - Failure Alert
    func showFailureAlert(forWorkflowType type: OstWorkflowType,
                          error: OstError? = nil,
                          onCompletion:((Bool) -> Void)? = nil) {
        
        let title = getWorkflowInterruptedText(workflowType: type)
        showFailureAlert(withTitle: title, onCompletion: onCompletion)
    }
    
    func showFailureAlert(withTitle title: String = "",
                          message msg: String = "",
                          onCompletion:((Bool) -> Void)? = nil) {
        
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
    
    
    //MARK: - Alert Text
    func getWorkflowCompleteText(workflowType: OstWorkflowType) -> String {
        
        switch workflowType {
        case .setupDevice:
            return ""
            
        case .activateUser:
            return ""
            
        case .addSession:
            return ""
            
        case .getDeviceMnemonics:
            return ""
            
        case .performQRAction:
            return ""
            
        case .executeTransaction:
            return ""
            
        case .authorizeDeviceWithQRCode:
            return ""
            
        case .authorizeDeviceWithMnemonics:
            return ""
            
        case .initiateDeviceRecovery:
            return ""
            
        case .abortDeviceRecovery:
            return ""
            
        case .revokeDeviceWithQRCode:
            return ""
            
        case .resetPin:
            return ""
            
        case .logoutAllSessions:
            return ""
            
        case .updateBiometricPreference:
            return ""
        }
    }
    
    func getWorkflowInterruptedText(workflowType: OstWorkflowType) -> String {
        
        switch workflowType {
        case .setupDevice:
            return ""
            
        case .activateUser:
            return ""
            
        case .addSession:
            return ""
            
        case .getDeviceMnemonics:
            return ""
            
        case .performQRAction:
            return ""
            
        case .executeTransaction:
            return ""
            
        case .authorizeDeviceWithQRCode:
            return ""
            
        case .authorizeDeviceWithMnemonics:
            return ""
            
        case .initiateDeviceRecovery:
            return ""
            
        case .abortDeviceRecovery:
            return ""
            
        case .revokeDeviceWithQRCode:
            return ""
            
        case .resetPin:
            return ""
            
        case .logoutAllSessions:
            return ""
            
        case .updateBiometricPreference:
            return ""
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
    fetchingUserBalance = "Fetching user balance...",
    creatingSession = "Creating Session...",
    authorizingDevice = "Authorizing Device....",
    revokingDevice = "Revoking Device..."
}
