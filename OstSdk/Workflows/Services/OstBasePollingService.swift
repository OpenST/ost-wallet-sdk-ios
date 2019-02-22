//
//  OstPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 13/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstBasePollingService {
    
    var maxRetryCount = 20
    let firstCallNo = 19
    let firstDelayTime = OstConstants.OST_BLOCK_FORMATION_TIME * 6
    
    var onSuccess: ((OstBaseEntity) -> Void)? = nil
    var onFailure: ((OstError) -> Void)? = nil
    
    let userId: String
    let workflowTransactionCount: Int
    
    let failuarCallback: ((OstError) -> Void)?
    var dispatchQueue: DispatchQueue = DispatchQueue.global()
    
    init (userId: String, workflowTransactionCount: Int, failuarCallback: ((OstError) -> Void)?) {
        self.userId = userId
        self.workflowTransactionCount = workflowTransactionCount
        self.failuarCallback = failuarCallback
    }
    
    func perform() {
        dispatchQueue.async {
            self.setupCallbacks()
            self.getEntityAfterDelay()
        }
    }
    
    func setupCallbacks() {
        self.onSuccess = { entity in
            self.onSuccessProcess(entity: entity)
        }
        
        self.onFailure = { error in
            self.failuarCallback?(error)
        }
    }
    
    func onSuccessProcess(entity: OstBaseEntity) {
        fatalError("onSuccessPerocess is not override.")
    }
    
    func getEntityAfterDelay() {
        Logger.log(message: "test getUserEntity for userId: \(userId) and is started at \(Date.timestamp())", parameterToPrint: "")
        self.maxRetryCount -= 1
        if (self.maxRetryCount >= 0) {
            
            let delayTime: Int = (self.maxRetryCount == self.firstCallNo) ? (self.firstDelayTime * workflowTransactionCount) : OstConstants.OST_BLOCK_FORMATION_TIME
            
            self.dispatchQueue.asyncAfter(deadline: .now() + .seconds(delayTime) ) {
                do {
                    Logger.log(message: "test loDispatchQueue for userId: \(self.userId) and is started at \(Date.timestamp())", parameterToPrint: "")
                    try self.fetchEntity()
                }catch let error {
                    self.failuarCallback?(error as! OstError)
                }
            }
        }else {
            self.failuarCallback?(OstError.actionFailed(""))
        }
    }
    
    func fetchEntity() throws {
        fatalError("fetchEntity is not override")
    }
}
