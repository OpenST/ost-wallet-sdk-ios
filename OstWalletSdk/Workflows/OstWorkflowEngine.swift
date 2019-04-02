/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstWorkflowEngine {
    
    let userId: String
    let delegate: OstWorkflowDelegate
    let workFlowValidator: OstWorkflowValidator
    let workflowStateManager: OstWorkflowStateManager

    var currentUser: OstUser? {
        do {
            return try OstUser.getById(self.userId)
        }catch {
            return nil
        }
    }
    var currentDevice: OstCurrentDevice? {
        return self.currentUser?.getCurrentDevice()
    }
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - delegate: Callback
    init(userId: String,
         delegate: OstWorkflowDelegate) {
        
        self.userId = userId
        self.delegate = delegate
        self.workFlowValidator = OstWorkflowValidator(withUserId: self.userId)
        self.workflowStateManager = OstWorkflowStateManager()
        
        self.workflowStateManager.setOrderedStates(
            getOrderedStates()
        )
    }
    
    /// Perform
    func perform() {
        let asyncQueue: DispatchQueue = DispatchQueue(label: "asyncThread")
        asyncQueue.async {
            let queue: DispatchQueue = self.getWorkflowQueue()
            queue.sync {
                do {
                    try self.process()
                }catch {
                    self.postError(error)
                }
            }
        }
    }
    
    /// Get workflow states in order
    ///
    /// - Returns: Workflow states
    func getOrderedStates() -> [String] {
        var orderedStates = [String]()
        
        let inBetweenStates = getInBetweenOrderedStates()
        
        orderedStates.append(OstWorkflowStateManager.INITIAL)
        orderedStates.append(OstWorkflowStateManager.PARAMS_VALIDATED)
        orderedStates.append(OstWorkflowStateManager.DEVICE_VALIDATED)
        orderedStates.append(contentsOf: inBetweenStates)
        orderedStates.append(OstWorkflowStateManager.COMPLETED)
        orderedStates.append(OstWorkflowStateManager.CANCELLED)
        
        return orderedStates
    }
    
    /// Process
    func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstWorkflowStateManager.INITIAL:
            try validateParams()
            
        case OstWorkflowStateManager.PARAMS_VALIDATED:
            try performUserDeviceValidation()
            try processNext()
            
        case OstWorkflowStateManager.DEVICE_VALIDATED:
            try onDeviceValidated()
            
        case OstWorkflowStateManager.COMPLETED:
            onWorkflowComplete()
            
        default:
            throw OstError("w_we_p_1", OstErrorText.unknown)
        }
    }
    
    /// Perfom next state
    ///
    /// - Parameter obj: Workflow state object
    func performNext(withObject obj: Any? = nil) {
        self.workflowStateManager.setNextState(withObject: obj)
        perform();
    }
    
    /// Process next state
    ///
    /// - Parameter obj: Workflow state object
    /// - Throws: OstError
    func processNext(withObject obj: Any? = nil) throws {
        self.workflowStateManager.setNextState(withObject: obj)
        try process();
    }
    
    /// Perform any tasks that are prerequisite for the workflow,
    /// this is called before validateParams() and process()
    ///
    /// - Throws: OstError
    func beforeProcess() throws {
        let group = DispatchGroup()
        group.enter()
        OstSdkSync(
            userId: self.userId,
            forceSync: false,
            syncEntites: .User, .Token, .CurrentDevice, onCompletion: { (isFetched) in
                group.leave()
        }
            ).perform()
        
        group.wait()
    }
    
    /// Validiate basic parameters for workflow
    ///
    /// - Throws: OstError
    func validateParams() throws {
       try processNext()
    }

    //MARK: - Methods to override
    
    /// Get worflow running queue.
    ///
    /// - Returns: DispatchQueue
    func getWorkflowQueue() -> DispatchQueue {
        fatalError("getWorkflowQueue not override.")
    }
    
    /// Proceed with workflow after user is authenticated.
    func proceedWorkflowAfterAuthenticateUser() {
        fatalError("processOperation is not override")
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    func getWorkflowContext() -> OstWorkflowContext {
        fatalError("getWorkflowContext not override.")
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    func getContextEntity(for entity: Any) -> OstContextEntity {
        fatalError("getContextEntity not override.")
    }
    
    ///Get inbeween states for workflow
    ///
    /// - Returns: Workflow states
    func getInBetweenOrderedStates() -> [String] {
       return []
    }
    
    
    /// Workflow complete process
    func onWorkflowComplete() {
        let workflowContext = getWorkflowContext()
        let contextEntity = OstContextEntity(entity: "", entityType: .string)
        postWorkflowComplete(workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    /// Perform user device validation
    ///
    /// - Throws: OstError
    func performUserDeviceValidation() throws {
        if(nil == self.currentUser) {
            throw OstError("w_we_vp_1", .userNotFound)
        }
        if(nil == self.currentDevice) {
            throw OstError("w_we_vp_2", .deviceNotSet)
        }
        try self.workFlowValidator.isAPIKeyAvailable()
        try self.workFlowValidator.isTokenAvailable()
        
        try beforeProcess()
    }
    
    /// On workflow validated
    func onDeviceValidated() throws {
        try processNext()
    }   
}


extension OstWorkflowEngine {
    
    /// Send callback to application if error occured in workflow.
    ///
    /// - Parameter error: OstError
    func postError(_ error: Error) {
        
        let errorWorkflowContext: OstWorkflowContext = self.getWorkflowContext()
        DispatchQueue.main.async {
            if ( error is OstError ) {
                self.delegate.flowInterrupted(workflowContext: errorWorkflowContext, error: error as! OstError);
            }
            else {
                //Unknown Error. Post Something went wrong.
                let ostError:OstError = OstError("w_we_pe_1", OstErrorText.sdkError)
                self.delegate.flowInterrupted(workflowContext: errorWorkflowContext, error: ostError )
            }
        }
    }
    
    /// Send callback to application about request has been sent to server.
    ///
    /// - Parameter entity: OstEntity whose response has received.
    func postRequestAcknowledged(entity: Any) {
        
        let ackWorkflowContext: OstWorkflowContext = getWorkflowContext()
        let contextEntity: OstContextEntity = getContextEntity(for: entity)
        DispatchQueue.main.async {
            self.delegate.requestAcknowledged(workflowContext: ackWorkflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Send workflow complete callback to user.
    ///
    /// - Parameter entity: OstEntity
    func postWorkflowComplete(entity: Any) {
        
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        let contextEntity: OstContextEntity = getContextEntity(for: entity)
        postWorkflowComplete(workflowContext: workflowContext,
                             contextEntity: contextEntity)
    }
    
    /// Send workflow complete callback to user.
    ///
    /// - Parameters:
    ///   - workflowContext: Workflow context
    ///   - contextEntity: Context entity
    func postWorkflowComplete(workflowContext: OstWorkflowContext,
                              contextEntity: OstContextEntity ) {
        DispatchQueue.main.async {
            self.delegate.flowComplete(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Cancel currently ongoing workflow.
    ///
    /// - Parameter cancelReason: reason to cancel.
    public func cancelFlow() {
        let ostError:OstError = OstError("w_wb_cf_1", OstErrorText.userCanceled)
        self.postError(ostError)
    }
}
