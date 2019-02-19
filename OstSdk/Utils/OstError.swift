//
//  OstError.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstError: Error {
    case invalidInput(String?), actionFailed(String?), unauthorized(String?)
    
    public var description: String? {
        switch self {
        case .invalidInput(let str):
            return str
        case .actionFailed(let str):
            return str
        case .unauthorized(let str):
            return str
        }
    }
}

public enum OstEntityError: Error {
    case validationFailed(String?)
}

public enum OstErrorType {
    case invalidInput, actionFailed
}
