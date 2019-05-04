//
//  BalanceModel.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class BalanceModel: OstBaseModel {
    static let getInstance = BalanceModel()
    
    //MARK: - Variable
    var balanceEntity: [String: Any]? = nil
}

extension BalanceModel {
    var balance: String? {
        return balanceEntity?["available_balance"] as? String
    }
}
