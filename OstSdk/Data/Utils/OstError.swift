//
//  OstError.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstError: Error {
    case invalidInput(String?)
    case actionFailed(String?)
}

public enum OstEntityError: Error {
    case validationFailed(String?)
}
