/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstTextViewConfig: OstBaseConfig {
    
    private let backgroundColor: String
    /// Initialize
    ///
    /// - Parameters:
    ///   - config: Config
    override init(config: [String: Any]) {
        self.backgroundColor = config["background_color"] as! String
        super.init(config: config)
    }
    
    //MARK: - Getter
    
    /// Get background color
    ///
    /// - Returns: Color
    func getBackgroundColor() -> UIColor {
        return UIColor.color(hex: backgroundColor)
    }
}
