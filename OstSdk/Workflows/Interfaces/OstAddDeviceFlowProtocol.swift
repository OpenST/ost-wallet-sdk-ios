//
//  OstAddDeviceFlowProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// Sub Interface of `OstPinAcceptProtocol` and `OstWalletWordsAcceptProtocol`.
public protocol OstAddDeviceFlowProtocol: OstPinAcceptProtocol, OstWalletWordsAcceptProtocol {
    
    /// SDK user will use it to start QRCode flow.
    ///
    /// - Parameter image: image of QR-Code
    func QRCodeFlow()
}
