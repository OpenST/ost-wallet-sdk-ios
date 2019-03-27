/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class BaseWalletWorkflowView: BaseWalletView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  
  // Mark - OstSdkInteract
  var sdkInteract: OstSdkInteract = {
    let interact = OstSdkInteract();
    return interact;
  }()
  
    func receivedSdkEvent(eventData: [String : Any]) {
        let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
        if ( OstSdkInteract.WorkflowEventType.requestAcknowledged == eventType ) {
            let timeStamp = String(Date().timeIntervalSince1970);
            addToLog(log: "☑️ Workflow request acknowledged at " + timeStamp);
        }
        else if ( OstSdkInteract.WorkflowEventType.flowComplete == eventType ) {
            let timeStamp = String(Date().timeIntervalSince1970);
            addToLog(log: "✅ Workflow completed at " + timeStamp);
            self.nextButton.isHidden = false;
            self.cancelButton.isHidden = false;
            self.activityIndicator.stopAnimating();
            
            let workflowContext:OstWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext;
            let workFlowType = workflowContext.workflowType;
            
            if ( workFlowType == .activateUser ) {
                self.successLabel.text = "Great! Your wallet has been setup."
            } else if ( workFlowType == .authorizeDeviceWithQRCode ) {
                self.successLabel.text = "This device has been authorized."
            } else if ( workFlowType == .addSession ) {
                self.successLabel.text = "The session on this device has been authorized."
            } else if ( workFlowType == .getDeviceMnemonics ) {
                self.successLabel.text = "Please note down these words."
            } else if ( workFlowType == .setupDevice ) {
                self.successLabel.text = "This device has been registered."
            } else if ( workFlowType == .resetPin ) {
                self.successLabel.text = "Pin reset successfully."
            } else if ( workFlowType == .initiateDeviceRecovery ) {
                self.successLabel.text = "Recover device successfully."
            }
            
        } else if (OstSdkInteract.WorkflowEventType.flowInterrupt == eventType ) {
            let timeStamp = String(Date().timeIntervalSince1970);
            addToLog(log: "⚠️ Workflow Failed at " + timeStamp);
            
            let error = eventData["ostError"] as! OstError;
            addToLog(log: "\nError.isApiError: \(error.isApiError)");
            addToLog(log: "\nError.localizedDescription: \(error.localizedDescription)");
            addToLog(log: "\nError.message: \(error.errorMessage)");
            addToLog(log: "\nError.messageTextCode: \(error.messageTextCode.rawValue)");
            addToLog(log: "\nError.internalCode: \(error.internalCode)");
            addToLog(log: "\nError.errorInfo:\n \(String(describing: error.errorInfo))");

            self.nextButton.isHidden = false;
            self.cancelButton.isHidden = false;
            self.activityIndicator.stopAnimating();

        } else if (OstSdkInteract.WorkflowEventType.getPinFromUser == eventType ) {
            let ostPinAcceptProtocol:OstPinAcceptDelegate = eventData["ostPinAcceptProtocol"] as! OstPinAcceptDelegate;
            getPinFromUser(ostPinAcceptProtocol: ostPinAcceptProtocol);
        }
    }
  
  override init(frame: CGRect) {
    super.init(frame: frame);
    sdkInteract.addEventListner { (eventData: [String : Any]) in
      self.receivedSdkEvent(eventData: eventData);
    };
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  func addToLog( log:String ) {
    var allLogs = (self.logsTextView.text != nil) ? self.logsTextView.text! : "";
    allLogs = allLogs + " \n" + log;
    self.logsTextView.text = allLogs;
  }
  
  @objc override func didTapNext(sender: Any) {
    super.didTapNext(sender: sender);
    let timeStamp = String(Date().timeIntervalSince1970);
    self.addToLog(log: "------------------------------");
    self.addToLog(log: "➡️ Starting Workflow at " + timeStamp + "");
  }
 
    let alertTitle = "Enter your pin"
    var alertMessage = ""
  func getPinFromUser(ostPinAcceptProtocol: OstPinAcceptDelegate) {
    let currentUser = CurrentUser.getInstance();
    let alert = UIAlertController(title: self.alertTitle, message: self.alertMessage, preferredStyle: UIAlertController.Style.alert);
    //Add a text field.
    alert.addTextField { (textField) in
        textField.placeholder = "6 digit pin"
        textField.keyboardType = .numberPad
        textField.isSecureTextEntry = true
        textField.textAlignment = .center;
    }
    //Add action
    let action = UIAlertAction(title: "Validate", style: .default) { (alertAction) in
      let pinTextField = alert.textFields![0] as UITextField
      if ((pinTextField.text?.count)! < 6 ) {
        self.alertMessage = "Invalid Pin";
        self.getPinFromUser(ostPinAcceptProtocol: ostPinAcceptProtocol)
        return;
      }
      ostPinAcceptProtocol.pinEntered(pinTextField.text!, passphrasePrefix: currentUser.userPinSalt!);
      alert.dismiss(animated: true, completion: nil);
    }
    alert.addAction(action);
    self.walletViewController?.present(alert, animated: true, completion: nil);
  }

}
