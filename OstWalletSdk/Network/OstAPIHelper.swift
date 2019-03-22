/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

enum ResultType: String {
    case token = "token"
    case user = "user"
    case device = "device"
    case deviceManager = "device_manager"
    case session = "session"
    case transaction = "transaction"
    case rules = "rules"
    case devices = "devices"
    case tokenHolder = "token_holder"
}

class OstAPIHelper {
    /// Add API params that are mandatory for calling the endpoint
    ///
    /// - Parameters:
    ///   - userId: UserId for which the API key is to be formed
    ///   - params: Request params
    /// - Throws: OSTError
    private class func addAPIParams(forUserId userId:String, inParams params: inout [String: Any]) throws {
        if (!userId.isEmpty) {
            guard let user: OstUser = try OstUser.getById(userId) else {
                throw OstError.init("n_ah_iapir_1", .userEntityNotFound)
            }
            if let currentDevice = user.getCurrentDevice() {
                params["api_signature_kind"] = OstConstants.OST_SIGNATURE_KIND
                params["api_request_timestamp"] = OstUtils.toString(Date.timestamp())
                params["api_key"] = "\(user.tokenId!).\(userId).\(currentDevice.address!).\(currentDevice.apiSignerAddress!)"
                return
            }
        }
        throw OstError.init("n_ah_iapir_2", .userEntityNotFound)
    }
    
    /// Sign the request params with API key
    ///
    /// - Parameter params: Request params
    /// - Throws: OSTError
    
    /// Sign the request params with API key with given userId's API key
    ///
    /// - Parameters:
    ///   - resource: Resource URL
    ///   - params: Request params
    ///   - userId:  UserId for which the API key will be used to sign the request url
    /// - Throws: OSTError
    class func sign(apiResource resource:String, andParams params: inout [String: Any], withUserId userId:String) throws {
        try OstAPIHelper.addAPIParams(forUserId: userId, inParams: &params)
        let signature =  try OstAPISigner(userId: userId).sign(resource: resource, params: params)
        params["api_signature"] = signature
    }
    
    
    
    /// Sync the entity data with API response
    ///
    /// - Parameter apiResponse: API response data
    /// - Returns: Entity object
    /// - Throws: OSTError
    class func syncEntityWithAPIResponse(apiResponse: [String: Any?]?) throws -> OstBaseEntity {
        if (apiResponse != nil) {
              do {
                try storeApiResponse(apiResponse!)
                return try getSyncedEntity(apiResponse!)
            }catch {
                throw OstError.init("n_ah_gefar_1", .entityNotAvailable)
            }
        }else {
            throw OstError.init("n_ah_gefar_2", .invalidAPIResponse)
        }
    }
    
    /// Sync the entities data with API response
    ///
    /// - Parameter apiResponse: API response data
    /// - Returns: Entity array
    /// - Throws: OSTError
    class func syncEntitiesWithAPIResponse(apiResponse: [String: Any?]?) throws -> [OstBaseEntity] {
        if (apiResponse != nil) {
            do {
                try storeApiResponse(apiResponse!)
                return try getSyncedEntities(apiResponse!)
            }catch {
                throw OstError.init("n_ah_seswar_1", .entityNotAvailable)
            }
        }else {
            throw OstError.init("n_ah_seswar_2", .invalidAPIResponse)
        }
    }
    
    /// Store the entities in the database from the API response
    ///
    /// - Parameter apiResponse: API response data
    /// - Throws: OSTError
    class func storeApiResponse(_ apiResponse: [String: Any?]) throws {
        let resultType = apiResponse["result_type"] as? String ?? ""
        let entityData =  apiResponse[resultType] as Any?
        
        if (nil == entityData) {
            return
        }

        switch resultType {
        case ResultType.token.rawValue:
            try OstToken.storeEntity(entityData as! [String: Any?])
        case ResultType.user.rawValue:
            try OstUser.storeEntity(entityData as! [String: Any?])
        case ResultType.device.rawValue:
            try OstDevice.storeEntity(entityData as! [String: Any?])
        case ResultType.deviceManager.rawValue:
            try OstDeviceManager.storeEntity(entityData as! [String: Any?])
        case ResultType.session.rawValue:
            try OstSession.storeEntity(entityData as! [String: Any?])
        case ResultType.transaction.rawValue:
            try OstTransaction.storeEntity(entityData as! [String: Any?])
        case ResultType.tokenHolder.rawValue:
            try OstTokenHolder.storeEntity(entityData as! [String: Any?])
        case ResultType.rules.rawValue:
            let rulesEntityData = entityData as! [[String: Any?]]
            for ruleEntityData in rulesEntityData {
                try OstRule.storeEntity(ruleEntityData)
            }
        case ResultType.devices.rawValue:
            let devicesEntityData = entityData as! [[String: Any?]]
            for deviceEntityData in devicesEntityData {
                try OstDevice.storeEntity(deviceEntityData)
            }
        default:
            return
        }
    }
    
    /// Get entity object for given entity type and primary key
    ///
    /// - Parameters:
    ///   - entityType: Entity type
    ///   - primaryKey: Primary key
    /// - Returns: OstBaseEntityObject
    /// - Throws: OstError
    private class func getSyncedEntity(_ apiResponse: [String: Any?]) throws -> OstBaseEntity {
        let resultType = apiResponse["result_type"] as? String ?? ""
        let entityData =  apiResponse[resultType] as? [String: Any?]
        
        if (entityData == nil) {
            throw OstError.init("n_ah_gse_1", .entityNotAvailable)
        }
        
        let getItem: ((String) throws -> String) = { (identifier) -> String in
            guard let id = OstUtils.toString(OstBaseEntity.getItem(fromEntity: entityData!, forKey: identifier) as Any?) else {
                throw OstError("n_ah_gse_2", .invalidEntityType)
            }
            return id
        }
        
        var id: String
        switch resultType {
        case ResultType.token.rawValue:
            id = try getItem(OstToken.ENTITY_IDENTIFIER)
            return try OstToken.getById(id)!
        case ResultType.user.rawValue:
            id = try getItem(OstUser.ENTITY_IDENTIFIER)
            return try OstUser.getById(id)!
        case ResultType.device.rawValue:
            id = try getItem(OstDevice.ENTITY_IDENTIFIER)
            return try OstDevice.getById(id)!
        case ResultType.deviceManager.rawValue:
            id = try getItem(OstDeviceManager.ENTITY_IDENTIFIER)
            return try OstDeviceManager.getById(id)!
        case ResultType.session.rawValue:
            id = try getItem(OstSession.ENTITY_IDENTIFIER)
            return try OstSession.getById(id)!
        case ResultType.transaction.rawValue:
            id = try getItem(OstTransaction.ENTITY_IDENTIFIER)
            return try OstTransaction.getById(id)!
        case ResultType.tokenHolder.rawValue:
            id = try getItem(OstTokenHolder.ENTITY_IDENTIFIER)
            return try OstTokenHolder.getById(id)!
        default:
            throw OstError("n_ah_gse_3", .invalidEntityType)
        }
    }
    
    /// Get entity array from database
    ///
    /// - Parameter apiResponse: API response
    /// - Returns: Entity array
    /// - Throws: OstError
    private class func getSyncedEntities(_ apiResponse: [String: Any?]) throws -> [OstBaseEntity] {
        let resultType = apiResponse["result_type"] as? String ?? ""
        let entityDataArray =  apiResponse[resultType] as? [[String: Any?]]
        Logger.log(message: "", parameterToPrint: entityDataArray)
        if (entityDataArray == nil) {
            throw OstError.init("n_ah_gses_1", .entityNotAvailable)
        }
        
        let getItem: ((String, [String: Any?]) throws -> String) = { (identifier, entityData) -> String in
            Logger.log(message: identifier, parameterToPrint: entityData)
            guard let id = OstUtils.toString(OstBaseEntity.getItem(fromEntity: entityData, forKey: identifier) as Any?) else {
                throw OstError("n_ah_gses_2", .invalidEntityType)
            }
            return id
        }
        
        var id: String
        var resultArray = [OstBaseEntity]()
        switch resultType {
        case ResultType.devices.rawValue:
            for entityData in entityDataArray!{
                id = try getItem(OstDevice.ENTITY_IDENTIFIER, entityData)
                let deviceObj = try OstDevice.getById(id)!
                resultArray.append(deviceObj)
            }
        default:
            throw OstError("n_ah_gses_3", .invalidEntityType)
        }
        
        return resultArray
    }
}
