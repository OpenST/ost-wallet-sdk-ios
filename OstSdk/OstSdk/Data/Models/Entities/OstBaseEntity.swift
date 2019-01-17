//
//  OstBaseEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstBaseEntity: NSObject {
    
    static let ID = "id"
    static let PARENT_ID = "parent_id"
    static let DATA = "data"
    static let STATUS = "status"
    static let UPDATED_TIMESTAMP = "updated_timestamp"
    
    public var id: String { return getId(data) }
    
    var parnetId: String? { return getParentId(data) }
    
    public var status: String? { return getStatus(data) }
    
    public var updated_timestamp: Int { return data[OstBaseEntity.UPDATED_TIMESTAMP] as? Int ?? 0 }
    
    var data: [String: Any] = ["id": String(Date.negativeTimestamp())]
    
    override init() {
        super.init()
    }
    
    init(_ params: [String: Any]) throws {
        super.init()
        
        let isValidParams = try validate(params)
        if (!isValidParams) {
            throw OstError.actionFailed("Object creation failed")
        }
        
        setParams(params)
    }

    //MARK: - validate
    func validate(_ params: [String: Any]) throws -> Bool {
        var isValid: Bool = false
       
        isValid = try isValidId(params[OstBaseEntity.ID])
    
        return isValid
    }
    
    func isValidId(_ id: Any?) throws -> Bool {
        if (id == nil) {
            return false
        }
        guard let idVal: String = OstUtils.toString(id) else {
            throw OstEntityError.validationFailed("id is not valid")
        }
        if (idVal.count < 1) { throw OstEntityError.validationFailed("id is not valid") }
        return true
    }
    
    //MARK: - set properties
    func setParams(_ params: [String: Any]) {
        self.data = params
    }
    
    func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstBaseEntity.ID])!
    }
    
    func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstBaseEntity.PARENT_ID])
    }
    
    func getStatus(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstBaseEntity.STATUS])
    }
}
