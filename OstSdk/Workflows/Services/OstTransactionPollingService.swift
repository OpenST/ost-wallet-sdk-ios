//
//  OstTransactionPollingService.swift
//  OstSdk
//
//  Created by aniket ayachit on 26/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTransactionPollingService: OstBasePollingService {
    let TransactionPollingServiceDispatchQueue = DispatchQueue(label: "com.ost.OstTransactionPollingService", qos: .background)
    
    let successCallback: ((OstTransaction) -> Void)?
    let transaciotnId: String
    init(userId: String,
         transaciotnId: String,
         workflowTransactionCount: Int,
         successCallback: ((OstTransaction) -> Void)?,
         failureCallback: ((OstError) -> Void)?) {
        
        self.successCallback = successCallback
        self.transaciotnId = transaciotnId
        super.init(userId: userId,
                   workflowTransactionCount: workflowTransactionCount,
                   failureCallback: failureCallback)
        
        self.dispatchQueue = self.TransactionPollingServiceDispatchQueue
    }
    
    override func onSuccessProcess(entity: OstBaseEntity) {
        let ostTransaction: OstTransaction = entity as! OstTransaction
        if (ostTransaction.isStatusSuccess) {
            Logger.log(message: "test User with userId: \(ostTransaction.id) and is success at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
            self.successCallback?(ostTransaction)
        }else if (ostTransaction.isStatusFailed){
            Logger.log(message: "test User with userId: \(ostTransaction.id) and is failed at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
            self.failureCallback?(OstError("w_s_tos_osp_1", OstErrorText.transactionFailed))
        }else {
            Logger.log(message: "test User status is activating for userId: \(ostTransaction.id) and is activated at \(Date.timestamp())", parameterToPrint: ostTransaction.data)
            self.getEntityAfterDelay()
        }
    }
    
    override func fetchEntity() throws {
        try OstAPITransaction(userId: userId).getTransaction(transcionId: self.transaciotnId,
                                                             onSuccess: self.onSuccess,
                                                             onFailure: self.onFailure)
    }
}
