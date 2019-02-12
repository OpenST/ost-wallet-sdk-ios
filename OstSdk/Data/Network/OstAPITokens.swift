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
    let tokenApiResourceBase = "/tokens"
    
    override init(userId: String) {
        super.init(userId: userId)
    }
    
    public func getToken(success:@escaping ((OstToken) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
    
        resourceURL = tokenApiResourceBase + "/"
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
    
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (tokenEntityData) in
            do {
                let resultType = tokenEntityData?["result_type"] as? String ?? ""
                if (resultType == "token") {
                    
                    let tokenEntity = tokenEntityData![resultType] as! [String : Any?]
                    
                    if let ostToken: OstToken = try OstToken.parse(tokenEntity ) {
                        success(ostToken)
                    }else {
                        failuar(OstError.actionFailed("Token Sync failed"))
                    }
                    
                }else {
                    failuar(OstError.actionFailed("Token Sync failed due to unexpected data format."))
                }
            }catch let error{
                failuar(error as! OstError)
            }
            
        }) { (failuarObj) in
            failuar(OstError.actionFailed("Token Sync failed"))
        }
    }
}
