/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstWorkflowEngine {
    static private let ostWorkflowEngineQueue = DispatchQueue(label: "com.ost.sdk.OstWorkflowEngine", qos: .userInitiated)
    let userId: String
    weak var delegate: OstWorkflowDelegate?
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
        self.workflowStateManager = OstWorkflowStateManager()
        
        self.workflowStateManager.setOrderedStates(
            getOrderedStates()
        )
    }
    
    /// Get workflow states in order
    ///
    /// - Returns: Workflow states
    func getOrderedStates() -> [String] {
        var orderedStates = [String]()
        
        orderedStates.append(OstWorkflowStateManager.INITIAL)
        orderedStates.append(OstWorkflowStateManager.PARAMS_VALIDATED)
        orderedStates.append(OstWorkflowStateManager.DEVICE_VALIDATED)
        
        orderedStates.append(OstWorkflowStateManager.COMPLETED)
        orderedStates.append(OstWorkflowStateManager.CANCELLED)
        
        return orderedStates
    }
    
    /// Perform
    func perform() {
        let asyncQueue: DispatchQueue = DispatchQueue(label: "asyncThread")
        asyncQueue.async {
            let queue: DispatchQueue = self.getCommonWorkflowQueue()
            queue.sync {
                do {
                    try self.process()
                }catch let error{
                    self.postError(error)
                }
            }
        }
    }
    
    /// Process
    func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstWorkflowStateManager.INITIAL:
            try validateParams()
            try onValidateParams()
            
        case OstWorkflowStateManager.PARAMS_VALIDATED:
            try performUserDeviceValidation()
            try onUserDeviceValidated()
            
        case OstWorkflowStateManager.DEVICE_VALIDATED:
            try onDeviceValidated()
            
        case OstWorkflowStateManager.COMPLETED:
            onWorkflowComplete()
            
        case OstWorkflowStateManager.CANCELLED:
            onWorkflowCancelled()

        case OstWorkflowStateManager.COMPLETED_WITH_ERROR:
            onCompleteWithError()
            
        default:
            throw OstError("w_we_p_2", OstErrorText.unknown)
        }
    }
    
    //MARK: - Methods to override
    
    /// Validiate basic parameters for workflow
    ///
    /// - Throws: OstError
    func validateParams() throws {
        //Common checks not present.
    }
    
    /// Process on params validated
    ///
    /// - Throws: OstError
    func onValidateParams() throws {
        try processNext()
    }
    
    /// Perform user device validation
    ///
    /// - Throws: OstError
    func performUserDeviceValidation() throws {
        //Ensure sdk can make Api calls
        try ensureApiCommunication()
        
        // Ensure we have OstUser complete entity.
        try ensureUser()
        
        // Ensure we have OstToken complete entity.
        try ensureToken()
        
        if shouldCheckCurrentDeviceAuthorization() {
            //Ensure Device is Authorized.
            try ensureDeviceAuthorized()
            
            //Ensures Device Manager is present as derived classes are likely going to need nonce.
            try ensureDeviceManager()
        }
    }
    
    /// Check for current device authorization
    ///
    /// - Returns: `true` if check required, else `false`
    func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return true
    }
    
    /// On user and device validated
    ///
    /// - Throws: OstError
    func onUserDeviceValidated() throws {
        //This can be derived by sub-class.
        //From here, sub-class can choose to 'jump' to other step by setting current-state = state-to-jump-to.
        //Here, the sub-class can also throw error, which will terminate the workflow after calling
        // postErrorInterupt.
        try processNext()
    }
    
    /// On device validated
    ///
    /// - Throws: OstError
    func onDeviceValidated() throws {
        try processNext()
    }
    
    /// Workflow complete process
    func onWorkflowComplete() {
        let workflowContext = getWorkflowContext()
        let contextEntity = OstContextEntity(entity: "", entityType: .string)
        postWorkflowComplete(workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    /// Perfrom action on workflow cancelled
    func onWorkflowCancelled() {
        let ostError:OstError = OstError("w_we_wc_1", OstErrorText.userCanceled)
        self.postError(ostError)
    }
    
    func onCompleteWithError() {
        let ostError:OstError = OstError("w_we_cwe_1", OstErrorText.userCanceled)
        self.postError(ostError)
    }
    
    /// Get worflow running queue.
    ///
    /// - Returns: DispatchQueue
    private func getCommonWorkflowQueue() -> DispatchQueue {
        return OstWorkflowEngine.ostWorkflowEngineQueue
    }

    /// Get worflow running queue.
    ///
    /// - Returns: DispatchQueue
    func getWorkflowQueue() -> DispatchQueue {
        fatalError("getWorkflowQueue not override.")
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
    
    // MARK: - States
    
    /// Perfom next state
    ///
    /// - Parameter obj: Workflow state object
    func performNext(withObject obj: Any? = nil) {
        self.workflowStateManager.setNextState(withObject: obj)
        perform();
    }
    
    /// Perfom next state
    ///
    /// - Parameter obj: Workflow state object
    func performState(_ state:String, withObject obj: Any? = nil) {
        self.workflowStateManager.setState(state, withObj: obj)
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
    
    /// Process next state
    ///
    /// - Parameter obj: Workflow state object
    /// - Throws: OstError
    func processState(_ state: String, withObject obj: Any? = nil) throws {
        self.workflowStateManager.setState(state, withObj: obj)
        try process();
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
                self.delegate?.flowInterrupted(workflowContext: errorWorkflowContext, error: error as! OstError);
            }
            else {
                //Unknown Error. Post Something went wrong.
                let ostError:OstError = OstError("w_we_pe_1", OstErrorText.sdkError)
                self.delegate?.flowInterrupted(workflowContext: errorWorkflowContext, error: ostError )
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
            self.delegate?.requestAcknowledged(workflowContext: ackWorkflowContext, ostContextEntity: contextEntity)
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
            self.delegate?.flowComplete(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Cancel currently ongoing workflow.
    ///
    /// - Parameter cancelReason: reason to cancel.
    public func cancelFlow() {
        try? self.processState(OstWorkflowStateManager.CANCELLED)
    }
}
