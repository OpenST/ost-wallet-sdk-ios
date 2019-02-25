//
//  OstUserPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 13/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift

class OstUserPollingService: OstBasePollingService {
    
    let UserPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstUserPollingService", qos: .background)
    
    let successCallback: ((OstUser) -> Void)?
    init(userId: String, workflowTransactionCount: Int, successCallback: ((OstUser) -> Void)?, failuarCallback: ((OstError) -> Void)?) {
        self.successCallback = successCallback
        super.init(userId: userId, workflowTransactionCount: workflowTransactionCount, failuarCallback: failuarCallback)
        self.dispatchQueue = UserPollingServiceDispatchQueue
    }
    
    override func onSuccessProcess(entity: OstBaseEntity) {
        let ostUser: OstUser = entity as! OstUser
        if (ostUser.isStatusActivating) {
            Logger.log(message: "test User status is activating for userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
            self.getEntityAfterDelay()
        }else{
            Logger.log(message: "test User with userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
            self.successCallback?(ostUser)
        }
    }

    override func fetchEntity() throws {
         try OstAPIUser.init(userId: self.userId).getUser(onSuccess: self.onSuccess, onFailure: self.onFailure)
    }
}
