//
//  OstAPIHelper.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

enum ResultType: String {
    case token = "token"
    case user = "user"
    case device = "device"
    case deviceManager = "device_manager"
    case session = "session"
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
    
    
    
    /// Get entity from API response
    ///
    /// - Parameter apiResponse: API response data
    /// - Returns: Entity object
    /// - Throws: OSTError
    class func getEntityFromAPIResponse(apiResponse: [String: Any?]?) throws -> OstBaseEntity {
        if (apiResponse != nil) {
              do {
                if let entity = try storeApiResponse(apiResponse!) {
                    return entity
                }else {
                    throw OstError.init("n_ah_gefar_1", .entityNotAvailable)
                }
            }catch {
                throw OstError.init("n_ah_gefar_2", .entityNotAvailable)
            }
        }else {
            throw OstError.init("n_ah_gefar_3", .invalidAPIResponse)
        }
    }
    
    /// Store the entities in the database from the API response
    ///
    /// - Parameter apiResponse: API response data
    /// - Returns: OST entity
    /// - Throws: OSTError
    class func storeApiResponse(_ apiResponse: [String: Any?]) throws -> OstBaseEntity? {
        let resultType = apiResponse["result_type"] as? String ?? ""
        let entityData =  apiResponse[resultType] as? [String: Any?]
        
        if (entityData == nil) {
            return nil
        }
        // TODO: Looks like parse is not correct term for insert and update
        switch resultType {
        case ResultType.token.rawValue:
            return try OstToken.parse(entityData!)
        case ResultType.user.rawValue:
            return try OstUser.parse(entityData!)
        case ResultType.device.rawValue:
            return try OstDevice.parse(entityData!)
        case ResultType.deviceManager.rawValue:
            return try OstDeviceManager.parse(entityData!)
        case ResultType.session.rawValue:
            return try OstSession.parse(entityData!)
        default:
            return nil
        }
    }
}
