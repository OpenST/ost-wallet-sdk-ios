//
//  OstContextEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstEntityType {
    case device, user, array, session, transaction, recoveryOwner
}

public class OstContextEntity {

    public private(set) var entity: Any?
    public private(set) var entityType: OstEntityType
    
    init(entity: Any, entityType: OstEntityType) {
        self.entity = entity as Any
        self.entityType = entityType
    }
}
