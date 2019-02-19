//
//  OstContextEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstWorkflowType {
    case setupDevice, activateUser
}

public enum OstEntityType {
    case currentDevice, user, ciImage
}

public class OstContextEntity {
    public private(set) var message: String
    public private(set) var type: OstWorkflowType
    public private(set) var entity: Any?
    public private(set) var entityType: OstEntityType
    
    init(message: String = "", type: OstWorkflowType, entity: Any? = nil, entityType: OstEntityType = .currentDevice) {
        self.message = message
        self.type = type
        self.entity = entity as Any
        self.entityType = entityType
    }
}
