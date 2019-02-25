//
//  OstBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 09/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkflowBase {
    var userId: String
    var delegate: OstWorkFlowCallbackProtocol
    
    init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        self.userId = userId
        self.delegate = delegate
    }
    
    func perform() {
        fatalError("************* perform didnot override ******************")
    }
    
    func getUser() throws -> OstUser? {
        return try OstUser.getById(self.userId)
    }
    
    func getCurrentDevice() throws -> OstCurrentDevice? {
        if let ostUser: OstUser = try getUser() {
            return ostUser.getCurrentDevice()
        }
        return nil
    }
    
    func postError(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate.flowInterrupt(error as? OstError ?? OstError.init("w_wfb_pe_1", .unexpectedError) )
        }
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
}
