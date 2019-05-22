/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public enum OstEntityType:Int {
    case device,
    user,
    array,
    session,
    transaction,
    recoveryOwner,
    string,
    dictionary,
    tokenHolder
}

@objc public class OstContextEntity: NSObject {

    @objc public private(set) var entity: Any?
    @objc public private(set) var entityType: OstEntityType
    
    init(entity: Any, entityType: OstEntityType) {
        self.entity = entity as Any
        self.entityType = entityType
    }
}
