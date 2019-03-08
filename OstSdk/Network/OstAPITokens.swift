//
//  OstTokensAPI.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class OstAPITokens: OstAPIBase {
    private let tokenApiResourceBase = "/tokens"
    
    /// Initializer
    ///
    /// - Parameter userId: User id to get token
    override init(userId: String) {
        super.init(userId: userId)
    }
    
    /// Get token. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getToken(onSuccess:((OstToken) -> Void)?,
                         onFailure:((OstError) -> Void)?) throws {
        resourceURL = tokenApiResourceBase + "/"
        var params: [String: Any] = [:]
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstToken)
                }catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
        
    }
}
