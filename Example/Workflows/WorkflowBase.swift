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
    let delegate: OstWorkFlowCallbackImplementation
    
    init(userId: String, tokenId: String) {
        self.userId = userId
        self.tokenId = tokenId
        
        delegate = OstWorkFlowCallbackImplementation()
    }
    
    func perform() throws {
        fatalError("perform did not overrid.")
    }
    
}
