//
//  BaseWalletWorkflowView.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
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
      addToLog(log: "☑️ Workflow Request Acknowledged.");
    } else if ( OstSdkInteract.WorkflowEventType.flowComplete == eventType ) {
      addToLog(log: "✅ Workflow Completed Successfully.");
      self.nextButton.isHidden = false;
      self.cancelButton.isHidden = false;
      self.activityIndicator.stopAnimating();
      self.successLabel.text = "Great! Your wallet has been setup."
    } else if (OstSdkInteract.WorkflowEventType.flowInterrupt == eventType ) {
      addToLog(log: "⚠️ Workflow Failed.");
      let error = eventData["ostError"] as! OstError;
      addToLog(log: "Error Description:" + error.description!);
    } else if (OstSdkInteract.WorkflowEventType.getPinFromUser == eventType ) {
      let ostPinAcceptProtocol:OstPinAcceptProtocol = eventData["ostPinAcceptProtocol"] as! OstPinAcceptProtocol;
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
    var allLogs = (self.logsLabel.text != nil) ? self.logsLabel.text! : "";
    allLogs += "\n" + log;
    self.logsLabel.text = allLogs;
    
  }
  
  @objc override func didTapNext(sender: Any) {
    super.didTapNext(sender: sender);
    self.logsLabel.text = "";
    self.addToLog(log: "➡️ Starting Workflow");
  }
 
  func getPinFromUser(ostPinAcceptProtocol: OstPinAcceptProtocol) {
    let currentUser = CurrentUser.getInstance();
    let alert = UIAlertController(title: "Enter your pin", message: "", preferredStyle: UIAlertController.Style.alert);
    //Add a text field.
    alert.addTextField { (textField) in
      textField.placeholder = "6 digit pin"
    }
    //Add action
    let action = UIAlertAction(title: "Validate", style: .default) { (alertAction) in
      let pinTextField = alert.textFields![0] as UITextField
      if ((pinTextField.text?.count)! < 6 ) {
        alert.message = "Invalid Pin";
        pinTextField.text = "";
        return;
      }
      ostPinAcceptProtocol.pinEntered(pinTextField.text!, applicationPassword: currentUser.userPinSalt!);
      alert.dismiss(animated: true, completion: nil);
    }
    alert.addAction(action);
    self.walletViewController?.present(alert, animated: true, completion: nil);
  }
}
