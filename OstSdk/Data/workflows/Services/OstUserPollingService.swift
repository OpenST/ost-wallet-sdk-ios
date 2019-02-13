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
    
    let UserPollingServiceDispatchQueue = DispatchQueue(label: "OstUserPollingService", qos: .background)
    
    let userId: String
    
    var onSuccess: ((OstUser) -> Void)? = nil
    var onFailure: ((OstError) -> Void)? = nil
    
    init(userId: String) {
        self.userId = userId
        super.init()
    }
    
    override func perform() {
        UserPollingServiceDispatchQueue.async { [weak self] in
            self!.setupCallbacks()
            self!.getUserEntity()
        }
    }

    func setupCallbacks() {
        self.onSuccess = { ostUser in
            if ((ostUser.status?.uppercased() == "ACTIVATING") ||
                (ostUser.tokenHolderAddress == nil) || (ostUser.deviceManagerAddress == nil)) {
                self.getUserEntity()
            }
        }
        
        self.onFailure = { ostError in
            
        }
    }
    
    func getUserEntity() {
        do {
            try OstAPIUser.init(userId: self.userId).getUser(success: onSuccess, failuar: onFailure)
        }catch {
            
        }
    }
}
