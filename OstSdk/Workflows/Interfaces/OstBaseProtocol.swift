//
//  OstBaseProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstBaseProtocol {
    
    /**
     Base Interface having SDK's flows common methods.
     
     - Parameter cancelReason: reason to cancel flow
    */
    func cancelFlow(_ cancelReason: String)
    
}
