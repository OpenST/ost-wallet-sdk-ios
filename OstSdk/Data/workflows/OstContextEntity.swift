//
//  OstContextEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstWorkflowType {
    case registerDevice
}

public class OstContextEntity {
    public private(set) var message: String
    public private(set) var type: OstWorkflowType
    public private(set) var entity: Any?
    
    init(message: String = "", type: OstWorkflowType, entity: OstBaseEntity? = nil) {
        self.message = message
        self.type = type
        self.entity = entity as Any
    }
}
