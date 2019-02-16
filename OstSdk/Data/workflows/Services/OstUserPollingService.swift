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
    
    var successCallback: ((OstUser) -> Void)? = nil
    var failuarCallback: ((OstError) -> Void)? = nil
    
    var onSuccess: ((OstUser) -> Void)? = nil
    var onFailure: ((OstError) -> Void)? = nil
    var dispatchQueue: DispatchQueue? = nil
    
    init(userId: String, successCallback: ((OstUser) -> Void)?, failuarCallback: ((OstError) -> Void)?) {
        
        self.successCallback = successCallback
        self.failuarCallback = failuarCallback
        
        super.init(userId: userId)
    }
    
    override func perform() {
        UserPollingServiceDispatchQueue.async {
            self.setupCallbacks()
            self.getUserEntity()
        }
    }
    
    func setupCallbacks() {
        self.onSuccess = { ostUser in
            if (ostUser.isActivating()) {
                Logger.log(message: "test User status is activating for userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
                self.getUserEntity()
            }else{
                Logger.log(message: "test User with userId: \(ostUser.id) and is activated at \(Date.timestamp())", parameterToPrint: ostUser.data)
                self.successCallback?(ostUser)
            }
        }
        
        self.onFailure = { error in
            self.failuarCallback?(error)
        }
    }
    
    func getUserEntity() {
        Logger.log(message: "test getUserEntity for userId: \(userId) and is started at \(Date.timestamp())", parameterToPrint: "")
        self.maxRetryCount -= 1
        if (self.maxRetryCount >= 0) {
            
            let delayTime: Int = (self.maxRetryCount == 9) ? self.firstDelayTime : OstConstants.OST_BLOCK_FORMATION_TIME
        
            let loDispatchQueue = dispatchQueue ?? DispatchQueue.main
            loDispatchQueue.asyncAfter(deadline: .now() + .seconds(delayTime) ) {
                do {
                    Logger.log(message: "test loDispatchQueue for userId: \(self.userId) and is started at \(Date.timestamp())", parameterToPrint: "")
                    try OstAPIUser.init(userId: self.userId).getUser(success: self.onSuccess, failuar: self.onFailure)
                }catch let error {
                    self.failuarCallback?(error as! OstError)
                }
            }
        }else {
            self.failuarCallback?(OstError.actionFailed(""))
        }
    }
}
