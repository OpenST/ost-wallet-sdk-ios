/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public class OstBaseEntity: NSObject {
    // The table column names.
    static let ID = "id"
    static let PARENT_ID = "parent_id"
    static let DATA = "data"
    static let STATUS = "status"
    static let UPDATED_TIMESTAMP = "updated_timestamp"
    
    /// Enitity data.
    private var entityData: [String: Any?] = [:]
    
    //MARK: - Initializer
    
     /// Initializer
     ///
     /// - Parameter enitityData: Entity data
     /// - Throws: OSTError
    init(_ entityData: [String: Any]) throws {
        super.init()
        try self.updateEntityData(entityData);
    }

    //MARK: - Validate
    
    /// Validate entity data
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Returns: `true` if valid, otherwise `false`
    private func validateEntityData(_ entityData: [String: Any]) throws {
        // Check if the id in entity data is valid.
        let isValid = isIdValid(entityData)
        if (!isValid) {
            throw OstError("m_e_be_ved_1", .invalidId)
        }
        // Add more validation code here.
    }
    
    /// Check if the id is valid
    ///
    /// - Parameter id: id string
    /// - Returns: `true` if valid, otherwise `false`
    private func isIdValid(_ entityData: [String: Any]) -> Bool {
        let id = OstUtils.toString(
            OstBaseEntity.getItem(fromEntity: entityData, forKey: self.getIdKey()) as Any?
        )
        if (id == nil) {
            return false
        }
        guard let idVal: String = OstUtils.toString(id) else {
            return false
        }
        return idVal.count > 1
    }
    
    //MARK: - Default lookup keys
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    func getIdKey() -> String {
        return OstBaseEntity.ID
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    func getParentIdKey() -> String {
        return OstBaseEntity.PARENT_ID
    }
    
    /// Get key identifier for data
    ///
    /// - Returns: Key identifier for data
    func getDataKey() -> String {
        return OstBaseEntity.DATA
    }
    
    /// Get key identifier for status
    ///
    /// - Returns: Key identifier for status
    func getStatusKey() -> String {
        return OstBaseEntity.STATUS
    }
    
    /// Get key identifier for updated timestamp
    ///
    /// - Returns: Key identifier for updated timestamp
    func getUpdatedTimestampKey() -> String {
        return OstBaseEntity.UPDATED_TIMESTAMP
    }
    
    /// Update entity data
    ///
    /// - Parameter entityData: Entity data
    /// - Throws: OSTError
    func updateEntityData(_ entityData: [String: Any]) throws{
        // Check if the provided entity data is valid.
        try self.validateEntityData(entityData)
        self.entityData = entityData
    }
    
    /// Get item for the given key from the entity data
    ///
    /// - Parameters:
    ///   - entityData: Entity data
    ///   - key: Key identifier
    /// - Returns: Object if found otherwise nil
    class func getItem(fromEntity entityData:[String:Any?], forKey key: String) -> Any? {
        guard let value: Any = entityData[key] as Any? else {
            return nil
        }
        return value
    }
}

public extension OstBaseEntity {
    /// Get the entity's id
    var id: String {
        let keyIdentifier = self.getIdKey()
        return OstUtils.toString(
            OstBaseEntity.getItem(fromEntity: self.entityData, forKey: keyIdentifier) as Any?
        )!
    }
    
    /// Get the entity's parent id
    var parentId: String? {
        let keyIdentifier = self.getParentIdKey()
        return OstUtils.toString(
            OstBaseEntity.getItem(fromEntity: self.entityData, forKey: keyIdentifier) as Any?
        )
    }
    
    /// Get the entity data
    @objc var data: [String: Any] {
        return self.entityData as [String : Any]
    }
    
    /// Get the entity's id
    var status: String? {
        let keyIdentifier = self.getStatusKey()
        if let statusValue = OstUtils.toString(
            OstBaseEntity.getItem(fromEntity: self.entityData, forKey: keyIdentifier) as Any?
            ) {
            return statusValue.uppercased()
        }
        return nil
    }
    
    /// Get the entity's updated timestamp
    var updatedTimestamp: TimeInterval {
        let keyIdentifier = self.getUpdatedTimestampKey()
        if let timeStamp = OstUtils.toString(OstBaseEntity.getItem(fromEntity: self.entityData, forKey: keyIdentifier) as Any?) {
            return TimeInterval(timeStamp) ?? 0
        }
        return 0
    }
}
