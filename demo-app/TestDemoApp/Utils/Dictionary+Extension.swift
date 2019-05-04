//
//  Dictionary+Extension.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension Dictionary{
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
