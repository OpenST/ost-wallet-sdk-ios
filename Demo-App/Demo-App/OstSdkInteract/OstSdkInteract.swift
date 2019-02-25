//
//  OstSdkInteract.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 15/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk
import MaterialComponents

class OstSdkInteract: BaseModel, OstWorkFlowCallbackProtocol {
  typealias OstSdkInteractEventHandler = ([String:Any]) -> ()
  
  public enum WorkflowEventType {
    case flowComplete
    case flowInterrupt
    case requestAcknowledged
    case getPinFromUser
    case showPinToUser
    case showPaperWallet
    case determineAddDeviceType
    case showQRCode
    case sendTransaction
  }
  
  let currentUser: CurrentUser;
  let appUserId: String;
  let tokenId: String;
  var eventHandlers:[OstSdkInteractEventHandler?];
  override init() {
    self.currentUser =  CurrentUser.getInstance();
    self.appUserId = self.currentUser.appUserId!;
    self.tokenId = self.currentUser.tokenId!;
    self.eventHandlers = [OstSdkInteractEventHandler]();
    super.init();
  }
  
  func isCurrentUser() -> Bool {
    let currentUser =  CurrentUser.getInstance();
    return self.appUserId == currentUser.appUserId;
  }
  
  func addEventListner(listner:OstSdkInteractEventHandler?) {
    self.eventHandlers.append(listner);
  }
  
  
  func fireEvent(eventData: [String:Any]) {
    let len = self.eventHandlers.count;
    for cnt in 0..<len {
      let currHandler:OstSdkInteractEventHandler? = self.eventHandlers[cnt];
      if ( currHandler == nil) {
        continue;
      }
      currHandler!(eventData);
    }
  }
  
  
  
}

// MARK: - Sdk Callbacks Implimentation.
extension OstSdkInteract {
  
  
  func registerDevice(_ apiParams: [String : Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol) {
    if ( !isCurrentUser() ) {
      ostDeviceRegisteredProtocol.cancelFlow("User logged-out");
      return;
    }
    
    //Make API call to Mappy App Server.
    let resourceUrl = "/users/" + self.appUserId + "/devices";
    self.post(resource: resourceUrl, params: apiParams as [String : AnyObject], onSuccess: { (appApiResponse:[String : Any]?) in
      try! ostDeviceRegisteredProtocol.deviceRegistered( appApiResponse! );
    }) { ([String : Any]?) in
      ostDeviceRegisteredProtocol.cancelFlow("Register device api error.");
    }
  }
  
  func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
    if ( !isCurrentUser() ) {
      ostPinAcceptProtocol.cancelFlow("User logged-out");
      return;
    }
    
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.getPinFromUser;
    eventData["ostPinAcceptProtocol"] = ostPinAcceptProtocol;
    self.fireEvent(eventData: eventData);
    
  }
  
  func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
    if ( !isCurrentUser() ) {
      ostPinAcceptProtocol.cancelFlow("User logged-out");
      return;
    }
    
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.getPinFromUser;
    eventData["ostPinAcceptProtocol"] = ostPinAcceptProtocol;
    self.fireEvent(eventData: eventData);

  }
  
  func pinValidated(_ userId: String) {
    
  }
  
  func flowComplete(_ ostContextEntity: OstContextEntity) {
    if ( !isCurrentUser() ) {
      //Ignore it.
      return;
    }
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.flowComplete;
//    eventData["workflow"] = ostContextEntity.type;
    eventData["ostContextEntity"] = ostContextEntity;
    self.fireEvent(eventData: eventData);
  }
    func flowComplete1(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        if ( !isCurrentUser() ) {
            //Ignore it.
            return;
        }
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.flowComplete;
        eventData["workflow"] = workflowContext.workflowType;
        eventData["ostContextEntity"] = ostContextEntity;
        eventData["workflowContext"] = workflowContext
        self.fireEvent(eventData: eventData);
    }
    
    func flowInterrupted(_ ostError: OstError) {
        if ( !isCurrentUser() ) {
            //Ignore it.
            return;
        }
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.flowInterrupt;
        eventData["ostError"] = ostError;
        self.fireEvent(eventData: eventData);
    }
    
    func flowInterrupted1(workflowContext: OstWorkflowContext, error: OstError) {
        if ( !isCurrentUser() ) {
            //Ignore it.
            return;
        }
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.flowInterrupt;
        eventData["ostError"] = error;
        self.fireEvent(eventData: eventData);
    }
    
  
  func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol) {
    if ( !isCurrentUser() ) {
      ostAddDeviceFlowProtocol.cancelFlow("User logged-out");
      return;
    }
    
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.determineAddDeviceType;
    eventData["ostAddDeviceFlowProtocol"] = ostAddDeviceFlowProtocol;
    self.fireEvent(eventData: eventData);
  }
  
  func showQR(_ startPollingProtocol: OstStartPollingProtocol, image qrImage: CIImage) {
    if ( !isCurrentUser() ) {
      startPollingProtocol.cancelFlow("User logged-out");
      return;
    }
    
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.showQRCode;
    eventData["startPollingProtocol"] = startPollingProtocol
    eventData["qrImage"] = qrImage;
    self.fireEvent(eventData: eventData);
    
  }
  
  func getWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
    if ( !isCurrentUser() ) {
      ostWalletWordsAcceptProtocol.cancelFlow("User logged-out");
      return;
    }
  }
  
  func invalidWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
    if ( !isCurrentUser() ) {
      ostWalletWordsAcceptProtocol.cancelFlow("User logged-out");
      return;
    }
  }
  
  func walletWordsValidated() {
    
  }
    
  func showPaperWallet(mnemonics: [String]) {
    var eventData:[String : Any] = [:];
    eventData["eventType"] = WorkflowEventType.showPaperWallet;
    eventData["mnemonics"] = mnemonics;
    self.fireEvent(eventData: eventData);
  }

  

}


