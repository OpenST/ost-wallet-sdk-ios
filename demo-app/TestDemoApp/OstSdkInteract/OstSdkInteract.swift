/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk
import MaterialComponents

class OstSdkInteract: BaseModel, OstWorkflowDelegate {
    
    typealias OstSdkInteractEventHandler = ([String:Any]) -> ()
    
    public enum WorkflowEventType {
        case flowComplete
        case flowInterrupt
        case requestAcknowledged
        case getPinFromUser
        case showPinToUser
        case showPaperWallet
        case determineAddDeviceType
        case verifyQRCodeData
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
    
    
    func registerDevice(_ apiParams: [String : Any],
                        delegate: OstDeviceRegisteredDelegate) {
        if ( !isCurrentUser() ) {
            delegate.cancelFlow();
            return;
        }
        
        //Make API call to Mappy App Server.
        let resourceUrl = "/users/" + self.appUserId + "/devices";
        self.post(resource: resourceUrl,
                  params: apiParams as [String : AnyObject],
                  onSuccess: { (appApiResponse:[String : Any]?) in
                    
                    try! delegate.deviceRegistered( appApiResponse! );
        }) { (failureResponse) in
            delegate.cancelFlow();
        }
    }
    
    func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        if ( !isCurrentUser() ) {
            delegate.cancelFlow();
            return;
        }
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.getPinFromUser;
        eventData["ostPinAcceptProtocol"] = delegate;
        self.fireEvent(eventData: eventData);
        
    }
    
    func invalidPin(_ userId: String,
                    delegate: OstPinAcceptDelegate) {
        
        if ( !isCurrentUser() ) {
            delegate.cancelFlow();
            return;
        }
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.getPinFromUser;
        eventData["ostPinAcceptProtocol"] = delegate;
        self.fireEvent(eventData: eventData);
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(workflowContext: OstWorkflowContext,
                      ostContextEntity: OstContextEntity) {
        
        if ( !isCurrentUser() ) {
            //Ignore it.
            return;
        }
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.flowComplete;
        eventData["workflowContext"] = workflowContext;
        eventData["ostContextEntity"] = ostContextEntity;
        self.fireEvent(eventData: eventData);
    }
    
    
    func flowInterrupted(workflowContext: OstWorkflowContext,
                         error: OstError) {
        
        if ( !isCurrentUser() ) {
            //Ignore it.
            return;
        }
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.flowInterrupt;
        eventData["workflow"] = workflowContext.workflowType;
        eventData["workflowContext"] = workflowContext;
        eventData["ostError"] = error;
        self.fireEvent(eventData: eventData);
    }

    func verifyData(workflowContext: OstWorkflowContext,
                    ostContextEntity: OstContextEntity,
                    delegate: OstValidateDataDelegate) {
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.verifyQRCodeData;
        eventData["workflowContext"] = workflowContext;
        eventData["ostContextEntity"] = ostContextEntity;
        eventData["delegate"] = delegate;
        self.fireEvent(eventData: eventData);
        
    }
    
    func requestAcknowledged(workflowContext: OstWorkflowContext,
                             ostContextEntity: OstContextEntity) {
        
        var eventData:[String : Any] = [:];
        eventData["eventType"] = WorkflowEventType.requestAcknowledged;
        eventData["workflowContext"] = workflowContext;
        eventData["ostContextEntity"] = ostContextEntity;
        self.fireEvent(eventData: eventData);
    }
}


