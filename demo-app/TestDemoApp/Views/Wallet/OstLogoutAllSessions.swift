//
//  OstLogoutAllSessions.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 22/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstWalletSdk

class OstLogoutAllSessions: AbortRevocerDeviceView {
    
    override func viewDidAppearCallback() {
        let currentUser = CurrentUser.getInstance()
        OstWalletSdk.logoutAllSessions(userId: currentUser.ostUserId!,
                                       delegate: self.sdkInteract)
    }
}
