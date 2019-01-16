//
//  OstBaseEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstBaseEntity: NSObject {
    
    enum EntityErrors: Error {
        case validationError(String)
    }
    
    public static let ID = "id"
    public static let PARENT_ID = "parent_id"
    public static let DATA = "data"
    public static let STATUS = "status"
    public static let UPDATED_TIMESTAMP = "updated_timestamp"
    
    public private(set) var id: String = String(Date.negativeTimestamp())
    public private(set) var parnet_id: String = ""
    private(set) var data: [String: Any] = ["id": String(Date.negativeTimestamp())]
    private(set) var status: String = ""
    public private(set) var updated_timestamp: Int = Date.negativeTimestamp()
    
//    init(_ params: [String: Any]) throws {
//        super.init()
//
//        let isValidParams = try validate(params)
//        if (!isValidParams) {
//            throw OstError.actionFailed("Object creation failed")
//        }
//
//        setParams(params)
//    }
    
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
            throw OstError.invalidInput("id is not valid")
        }
        if (idVal.count < 1) { throw OstError.invalidInput("id is not valid") }
        return true
    }
    
    //MARK: - set properties
    func setParams(_ params: [String: Any]) {
        self.id = getId(params)
        getParentId(params).map { self.parnet_id = $0}
        
        self.data = params
        OstUtils.toString(params[OstBaseEntity.STATUS]).map { self.status = $0 }
        self.updated_timestamp = params[OstBaseEntity.UPDATED_TIMESTAMP] as? Int ?? 0
        
    }
    
    func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstBaseEntity.ID])!
    }
    
    func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstBaseEntity.ID])
    }
}
