/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstWorkflowStateManager {
    
    static let INITIAL = "INITIAL"
    static let PARAMS_VALIDATED = "PARAMS_VALIDATED"
    static let DEVICE_VALIDATED = "DEVICE_VALIDATED"
    static let VERIFY_DATA = "VERIFY_DATA"
    static let DATA_VERIFIED = "DATA_VERIFIED"
    static let CALLBACK_LOST = "CALLBACK_LOST"
    static let CANCELLED = "CANCELLED"
    static let COMPLETED_WITH_ERROR = "COMPLETED_WITH_ERROR"
    static let COMPLETED = "COMPLETED"
    static let UNEXPECTED = "UNEXPECTED"
    
    private var orderedStates = [String]()
    private var currentStateIndex: Int = 0
    private var stateObject: Any? = nil
    
    /// Initialize
    init() {}
    
    //MARK: - State
    
    /// Get current state value
    ///
    /// - Returns: Current state string value
    func getCurrentState() -> String {
        if self.orderedStates.count > currentStateIndex {
            return self.orderedStates[currentStateIndex]
        }
        return OstWorkflowStateManager.UNEXPECTED
    }
    
    /// Get next state value
    ///
    /// - Returns: Next state string value
    func getNextState() -> String {
        let stateIndex = currentStateIndex + 1
        if self.orderedStates.count > stateIndex {
            return self.orderedStates[stateIndex]
        }
        return OstWorkflowStateManager.UNEXPECTED
    }
    
    /// Set next state
    ///
    /// - Parameter obj: Object for next state, default is `nil`
    func setNextState(withObject obj: Any? = nil) {
        self.currentStateIndex += 1
        setStateObject(obj)
    }
    
    /// Set state
    ///
    /// - Parameters:
    ///   - state: WorkflowStateManager.State
    ///   - obj: State object
    /// - Throws: OstError
    func setState(_ state: String, withObj obj: Any? = nil) {
        let stateIndx = self.orderedStates.firstIndex(of: state)
        self.currentStateIndex = stateIndx!
        self.stateObject = obj
    }
    
    //MARK: - State Object
    
    /// Set current state object
    ///
    /// - Parameter obj: State object
    func setStateObject(_ obj: Any? = nil) {
        self.stateObject = obj
    }
    
    /// Get state object
    ///
    /// - Returns: State object
    func getStateObject() -> Any? {
        return self.stateObject
    }
    
    /// Set ordered states
    ///
    /// - Parameter states: States array
    func setOrderedStates(_ states: [String]) {
        self.orderedStates = states
    }
}

