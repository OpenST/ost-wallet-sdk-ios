//
//  Dictionary+Conversion.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension Dictionary{
    func toData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject:self)
    }
}
