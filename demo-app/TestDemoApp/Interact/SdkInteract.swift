/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class WeakRef<T> where T: AnyObject {
    
    private(set) weak var value: T?
    init(value: T?) {
        self.value = value
    }
}

struct EventHandler {
    var delegate: OstBaseDelegate?
    var workflowContext: OstWorkflowContext?
    var contextEntity: OstContextEntity?
    var error: OstError?
    
    let workflowId: String
    let eventType: EventType
    
    init(workflowId: String, eventType: EventType) {
        self.workflowId = workflowId
        self.eventType = eventType
    }
}

enum EventType {
    case register,
    getPin,
    invalidPin,
    pinValidated,
    flowComplete,
    flowInterrupted,
    verifyData,
    requestAcknowledged
}

class Events {
    private var event: [EventType: [WeakRef<AnyObject>]] = [:]
    
    init(eventType: EventType, listner: SdkInteractDelegate) {
        let weakListner = WeakRef<AnyObject>(value: listner)
        let listners: [WeakRef<AnyObject>] = [weakListner]
        self.event[eventType] = listners
    }
    
    func appendEventListner(_ listner: SdkInteractDelegate, forEventType eventType: EventType) {
        let weakListner = WeakRef<AnyObject>(value: listner)
        var listners: [WeakRef<AnyObject>]? = event[eventType]
        if nil == listners{
            listners = [weakListner]
        }else {
            listners!.append(weakListner)
        }
        self.event[eventType] = listners!
    }
    
    func getEventListners(forEventType eventType: EventType) -> [WeakRef<AnyObject>]? {
        return self.event[eventType]
    }
}

class SdkInteract {
    static let getInstance = SdkInteract()
    private init() {}
    private var callbacks: [String: Events] = [:]
    
    func getCallbackEventFor(workflowId id: String) ->  Events? {
        return callbacks[id]
    }
    
    func getCallbackEventListners(workflowId: String, eventType: EventType) -> [WeakRef<AnyObject>]? {
        guard let event: Events = self.callbacks[workflowId] else {
            return nil
        }
        return event.getEventListners(forEventType: eventType)
    }
    
    func subscribeForWorkflow(workflowId: String, eventType: EventType, listner: SdkInteractDelegate) {
        if let event = getCallbackEventFor(workflowId: workflowId) {
            event.appendEventListner(listner, forEventType: eventType)
            
        }else {
            let event = Events(eventType: eventType, listner: listner)
            self.callbacks[workflowId] = event
        }
    }
    
    func removeEventListners(forWorkflowId id: String) {
        self.callbacks[id] = nil
    }
}

extension SdkInteract {
    func registerDevice(apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        
    }
    
    func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        
    }
    
    func invalidPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
    }
    
    func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    func verifyData(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity, delegate: OstValidateDataDelegate) {
        
    }
    
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
    }
}
