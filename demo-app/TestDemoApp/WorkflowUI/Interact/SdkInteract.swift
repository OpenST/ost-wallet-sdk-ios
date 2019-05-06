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

class SdkInteract {
    static let getInstance = SdkInteract()
    private init() {}
    private var callbackListners: [String: [OstWeakRef<AnyObject>]] = [:]
    private var workflowCallbackList: [WorkflowCallbacks] = []
    
    func getWorkflowCallback() -> WorkflowCallbacks {
        let workflow = WorkflowCallbacks()
        workflowCallbackList.append(workflow)
        return workflow
    }
    
    func getEventListner(forWorkflowId id: String) ->  [OstWeakRef<AnyObject>]? {
        return self.callbackListners[id]
    }
    
    func subscribe(forWorkflowId workflowId: String, listner: SdkInteractDelegate) {
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
                (eventListner.value as? FlowCompleteDelegate)?.flowComplete(workflowId: workflowId,
                                                                            workflowContext: eventHandler.workflowContext!,
                                                                            contextEntity: eventHandler.contextEntity!)
                
            case .flowInterrupted:
                (eventListner.value as? FlowInterruptedDelegate)?.flowInterrupted(workflowId: workflowId,
                                                                                  workflowContext: eventHandler.workflowContext!,
                                                                                  error: eventHandler.error!)
                
            case .requestAcknowledged:
                (eventListner.value as? RequestAcknowledgedDelegate)?.requestAcknowledged(workflowId: workflowId,
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
