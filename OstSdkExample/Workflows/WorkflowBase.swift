//
//  WorkflowBase.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class WorkflowBase {
    var userId: String
    var tokenId: String
    var mappyUserId: String
    
    let delegate: OstWorkFlowCallbackImplementation
    
    init(userId: String, tokenId: String, mappyUserId: String) {
        self.userId = userId
        self.tokenId = tokenId
        self.mappyUserId = mappyUserId
        
        delegate = OstWorkFlowCallbackImplementation(mappyUserId: mappyUserId)
    }
    
    func perform() throws {
        fatalError("perform did not overrid.")
    }
    
}
