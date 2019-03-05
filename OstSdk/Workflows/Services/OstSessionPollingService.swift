//
//  OstSessionPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSessionPollingService: OstBasePollingService {
    let sessionPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstSessionPollingService", qos: .background)
    
    let successCallback: ((OstSession) -> Void)?
    let sessionAddress: String
    init(userId: String, sessionAddress: String, workflowTransactionCount: Int, successCallback: ((OstSession) -> Void)?, failureCallback: ((OstError) -> Void)?) {
        self.sessionAddress = sessionAddress
        self.successCallback = successCallback
        super.init(userId: userId, workflowTransactionCount: workflowTransactionCount, failureCallback: failureCallback)
    }
    
    override func onSuccessProcess(entity: OstBaseEntity) {
        let ostSession: OstSession = entity as! OstSession
        if (ostSession.isStatusInitializing) {
            Logger.log(message: "[\(Date.timestamp())]: Session status is activating for userId: \(ostSession.id) and is Initializing.", parameterToPrint: ostSession.data)
            self.getEntityAfterDelay()
        }else{
          Logger.log(message: "[\(Date.timestamp())]: Session with userId: \(ostSession.id) and is activated.", parameterToPrint: ostSession.data)
            self.successCallback?(ostSession)
        }
    }
    
    override func fetchEntity() throws {
        try OstAPISession(userId: self.userId).getSession(sessionAddress: sessionAddress, onSuccess: self.onSuccess, onFailure: onFailure)
    }
    
    override func getPollingQueue() -> DispatchQueue {
        return self.sessionPollingServiceDispatchQueue
    }
}
