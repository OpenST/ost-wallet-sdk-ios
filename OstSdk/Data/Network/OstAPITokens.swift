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
    
    let userApiResourceBase = "/tokens"
    
    var tokenId: String
    
    init(userId: String, tokenId: String) {
        self.tokenId = tokenId
        super.init(userId: userId)
    }
    
    public func getToken(success:@escaping ((OstToken) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (tokenEntityData) in
            do {
                if let ostToken: OstToken = try OstToken.parse(tokenEntityData) {
                    success(ostToken)
                }else {
                    failuar(OstError.actionFailed("Token Sync failed"))
                }
            }catch {
                failuar(OstError.actionFailed("Token Sync failed"))
            }
            
        }) { (failuarObj) in
            failuar(OstError.actionFailed("Token Sync failed"))
        }
    }
}
