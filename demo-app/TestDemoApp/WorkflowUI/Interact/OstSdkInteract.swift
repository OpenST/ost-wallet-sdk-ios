/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstWeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    init(value: T?) {
        self.value = value
    }
}

struct OstInteractEventData {
    var delegate: OstBaseDelegate?
    var workflowContext: OstWorkflowContext?
    var contextEntity: OstContextEntity?
    var error: OstError?
    var data: Any?
}

enum OstInteractEventType {
    case register,
    getPin,
    invalidPin,
    pinValidated,
    flowComplete,
    flowInterrupted,
    verifyData,
    requestAcknowledged,
    all
}

class OstSdkInteract {
    static let getInstance = OstSdkInteract()
    private init() {}
    private var callbackListners: [String: [OstWeakRef<AnyObject>]] = [:]
    private var workflowCallbackList: [OstWorkflowCallbacks] = []
    
    func getWorkflowCallback(forUserId userId: String) -> OstWorkflowCallbacks {
        let callback = OstWorkflowCallbacks(userId: userId, passphrasePrefixDelegate: CurrentUserModel.getInstance);
        retainWorkflowCallback(callback: callback);
        return callback;
    }
    
    func retainWorkflowCallback(callback: OstWorkflowCallbacks) {
        workflowCallbackList.append(callback);
    }
    
    func getEventListner(forWorkflowId id: String) ->  [OstWeakRef<AnyObject>]? {
        return self.callbackListners[id]
    }
    
    func subscribe(forWorkflowId workflowId: String, listner: OstSdkInteractDelegate) {
        var loListners = getEventListner(forWorkflowId: workflowId) ?? []
        
        for loListner in loListners {
            let wListner = loListner.value
            if wListner === listner {
                return
            }
        }
        let weakListner = OstWeakRef<AnyObject>(value: listner)
        loListners.append(weakListner)
        self.callbackListners[workflowId] = loListners
    }
    
    func unsubscribe(forWorkflowId workflowId: String, listner: OstSdkInteractDelegate) {
        guard var listners = callbackListners[workflowId] else {return}
        
        for (index, weakListner) in listners.enumerated() {
            if let obj = weakListner.value,
                obj === listner{
                
                listners.remove(at: index)
            }
        }
        callbackListners[workflowId] = listners
    }
    
    func removeEventListners(forWorkflowId id: String) {
        self.callbackListners[id] = nil
        for (i,workflowCallback) in workflowCallbackList.enumerated() {
            let wfId = workflowCallback.workflowId
            if wfId.caseInsensitiveCompare(id) == .orderedSame {
                workflowCallbackList.remove(at: i)
                break
            }
        }
    }
    
    func broadcaseEvent(workflowId: String, eventType: OstInteractEventType, eventHandler: OstInteractEventData) {
        guard let eventListners =
            getEventListner(forWorkflowId: workflowId)
            else {
                return
        }
        
        for eventListner in eventListners {
            switch eventType {
            case .flowComplete:
                (eventListner.value as? OWFlowCompleteDelegate)?.flowComplete(workflowId: workflowId,
                                                                               workflowContext: eventHandler.workflowContext!,
                                                                               contextEntity: eventHandler.contextEntity!)
                
            case .flowInterrupted:
                (eventListner.value as? OWFlowInterruptedDelegate)?.flowInterrupted(workflowId: workflowId,
                                                                                     workflowContext: eventHandler.workflowContext!,
                                                                                     error: eventHandler.error!)
                
            case .requestAcknowledged:
                (eventListner.value as? OWRequestAcknowledgedDelegate)?.requestAcknowledged(workflowId: workflowId,
                                                                                          workflowContext: eventHandler.workflowContext!,
                                                                                          contextEntity: eventHandler.contextEntity!)
            default:
                continue
                
            }
        }
        if eventType == .flowComplete || eventType == .flowInterrupted {
            removeEventListners(forWorkflowId: workflowId)
        }
    }
}
