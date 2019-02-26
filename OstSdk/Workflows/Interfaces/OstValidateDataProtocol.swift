//
//  OstActionConfirmProtocol.swift
//  OstSdk
//
//  Created by Rachin Kapoor on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstValidateDataProtocol: OstBaseProtocol {
    
    /// Confirm desired action taken by user.
    func dataVerified()
}
