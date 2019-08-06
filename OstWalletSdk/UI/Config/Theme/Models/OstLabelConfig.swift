//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import Foundation

@objc class OstLabelConfig: OstBaseConfig {
    
    let alignment: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - config: Config
    override init(config: [String: Any]) {
        self.alignment = config["alignment"] as! String
        super.init(config: config)
    }
    
    func getAlignment() -> NSTextAlignment {
        return UIFont.getAlignmentFromString(alignment)
    }
}