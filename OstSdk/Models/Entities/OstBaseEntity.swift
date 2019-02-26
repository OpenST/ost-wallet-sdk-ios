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
    
    public internal(set) var data: [String: Any?] = ["id":String(Date.negativeTimestamp())]
    
    override init() {
        super.init()
    }
    
     init(_ params: [String: Any]) throws {
        super.init()
        
        let isValidParams = try validate(params)
        if (!isValidParams) {
            throw OstError.init("m_e_be_i", .objectCreationFailed)
        }
        
        setParams(params)
    }

    //MARK: - validate
    func validate(_ params: [String: Any]) throws -> Bool {
        var isValid: Bool = false
       
        isValid = try isValidId(self.getId(params))
    
        return isValid
    }
    
    func isValidId(_ id: Any?) throws -> Bool {
        if (id == nil) {
            return false
        }
        guard let idVal: String = OstUtils.toString(id) else {
            throw OstError.init("m_e_be_iv_1", .invalidId);
        }
        if (idVal.count < 1) { throw OstError.init("m_e_be_iv_2", .invalidId); }
        return true
    }
    
    //MARK: - set properties
    func setParams(_ params: [String: Any]) {
        data = params
    }
    
    func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstBaseEntity.ID] as Any?)!
    }
    
    func getParentId() -> String? {
        return OstUtils.toString(self.data[OstBaseEntity.PARENT_ID] as Any?)
    }
    
    func processJson(_ entityData: [String: Any?]){
        self.data = entityData
    }
}


extension OstBaseEntity {
    public var id: String { return getId() }
    
    var parnetId: String? { return getParentId() }
    
    public var status: String? {
        if let status = self.data[OstBaseEntity.STATUS] {
            if let statusStringVal = OstUtils.toString(status as Any) {
                return statusStringVal.uppercased()
            }
        }
        return nil
    }
    
    public var updated_timestamp: Int { return OstUtils.toInt(data[OstBaseEntity.UPDATED_TIMESTAMP] as Any?) ?? 0}
}
