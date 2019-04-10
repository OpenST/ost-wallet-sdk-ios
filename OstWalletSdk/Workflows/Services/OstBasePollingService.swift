/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstBasePollingService {
    private static let MAX_RETRY_COUNT = 20
    private static let NO_OF_CONFIRMATION_BLOCKS = 6;
    private let workflowTransactionCount: Int
    private let successStatus: String
    private let failureStatus: String
    
    let userId: String
    let failureCallback: ((OstError) -> Void)?
    
    var requestCount = 0;
    var onSuccess: ((OstBaseEntity) -> Void)? = nil
    var onFailure: ((OstError) -> Void)? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - successStatus: Entity success status
    ///   - failureStatus: Entity failure status
    ///   - workflowTransactionCount: workflow transaction count
    ///   - failureCallback: Failure callback
    init (userId: String,
          successStatus: String,
          failureStatus: String,
          workflowTransactionCount: Int,
          failureCallback: ((OstError) -> Void)?) {
        
        self.userId = userId
        self.successStatus = successStatus
        self.failureStatus = failureStatus
        self.workflowTransactionCount = workflowTransactionCount
        self.failureCallback = failureCallback
    }
    
    /// Perform
    func perform() {
        let queue: DispatchQueue = getPollingQueue()
        queue.async {
            self.setupCallbacks()
            self.getEntityAfterDelay()
        }
    }
    
    /// Setup callback for API
    func setupCallbacks() {
        self.onSuccess = { entity in
            self.onSuccessProcess(entity: entity)
        }
        
        self.onFailure = { error in
            self.failureCallback?(error)
        }
    }
    
    /// Get entity after delay
    func getEntityAfterDelay() {
      // Logger.log(message: "[\(Date.timestamp())]: getEntityAfterDelay: for userId: \(userId)", parameterToPrint: "")
        //check for max retry count
        if (self.requestCount < OstBasePollingService.MAX_RETRY_COUNT ) {
            let delayTime: Int;
            //check request count of polling.
            //If request count is 0 then start polling after
            //delay = (BLOCK_GENERATION_TIME + CONFIRMATION_BLOCKS + 1(Buffer)) * WORKFLOW_TRANSACTION_COUNT
            if (self.requestCount > 0 ) {
              delayTime = OstConfig.getBlockGenerationTime()
            } else {
              delayTime = OstConfig.getBlockGenerationTime() * (OstBasePollingService.NO_OF_CONFIRMATION_BLOCKS + 1 ) * workflowTransactionCount;
            }
            
            let queue: DispatchQueue = self.getPollingQueue()
            queue.asyncAfter(deadline: .now() + .seconds(delayTime) ) {
                do {
                    self.requestCount += 1
                    // Logger.log(message: "[\(Date.timestamp())]: loDispatchQueue for userId: \(self.userId) and is started at \(Date.timestamp())", parameterToPrint: "")
                    try self.fetchEntity()
                }catch let error {
                    let ostError = error as! OstError;
                    /// TODO: Check response error code.
                    /// If it was a network error (The following status code should not be treated as network-errors: 200/404/401)
                    /// We need to retry instead of calling failureCallback.
                    /// For now, we shall check on requestCount
                    if ( self.requestCount == OstBasePollingService.MAX_RETRY_COUNT ) {
                      //Sufficient retires have been made.
                      self.failureCallback?(ostError)
                      return;
                    }
                  
                    // Lets Retry.
                    self.getEntityAfterDelay()
                }
            }
        }else {
            self.failureCallback?(OstError("w_s_bps_gead_1", .requestTimedOut))
        }
    }
    
    /// Process entity after getting success callback from server
    ///
    /// - Parameter entity: Device entity
    func onSuccessProcess(entity: OstBaseEntity) {
        if (entity.status!.caseInsensitiveCompare(self.successStatus) == .orderedSame) {
            // Logger.log(message: "test User with userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.postSuccessCallback(entity: entity)
            
        }else if (entity.status!.caseInsensitiveCompare(self.failureStatus) == .orderedSame){
            self.failureCallback?(OstError("w_s_bps_osp_1", OstErrorText.failedToProcess) )
            
        }else{
            // Logger.log(message: "test User status is activating for userId: \(ostDevice.id) and is activated at \(Date.timestamp())", parameterToPrint: ostDevice.data)
            self.getEntityAfterDelay()
        }
    }
    
    //MARK: - Methods to override
    
    /// Fetch entity from server
    ///
    /// - Throws: OstError
    func fetchEntity() throws {
        fatalError("fetchEntity is not override")
    }
    
    /// Post success callback
    ///
    /// - Parameter entity: OstEntity
    func postSuccessCallback(entity: OstBaseEntity) {
        fatalError("postSuccessCallback is not override")
    }
    
    /// Get polling queue
    ///
    /// - Returns: DispatchQueue
    func getPollingQueue() -> DispatchQueue {
        fatalError("getPollingQueue is not override.")
    }
}
