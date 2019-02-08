//
//  DeployTokenHolder.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class DeployTokenHolder: WorkflowBase {

    override func perform() throws {
        do {
            try OstSdk.deployTokenHolder(userId: userId, spendingLimit: "10000", expirationHeight: "12345", delegate: delegate)
        }catch let error {
            print(error)
        }
    }
}
