//
//  OstWalletWordsAcceptProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// Sub Interface of `OstBaseInterface` It declares pinEntered api of Workflows.
public protocol OstWalletWordsAcceptProtocol: OstBaseProtocol {
    
    /// SDK user will use it to pass wallet 12 words to SDK.
    ///
    /// - Parameter wordList: List of wallet 12 words
    func walletWordsEntered(_ wordList: String)
}
