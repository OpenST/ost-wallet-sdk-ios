//
//  Data+Dictionary.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension Data{
    func toDictionary() -> Dictionary<String, Any> {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as! Dictionary<String, Any>
    }
}
