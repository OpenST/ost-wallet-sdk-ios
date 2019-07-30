//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstBaseConfig: NSObject {
    
    let fontName: String
    let size: NSNumber
    let colorHex: String
    let fontStyle: String
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - config: Config
    ///   - defaultConfig: Fallback config
    init(config: [String: Any]?,
         defaultConfig: [String: Any]) {
        
        self.fontName = (config?["font"] as? String) ?? ""
        self.size = (config?["size"] as? NSNumber) ?? (defaultConfig["size"] as! NSNumber)
        self.colorHex = (config?["color"] as? String) ?? (defaultConfig["color"] as! String)
        self.fontStyle = (config?["font_style"] as? String) ?? (defaultConfig["font_style"] as! String)
    }
    
    /// Get font for provided config
    ///
    /// - Parameter weight: Font weight
    /// - Returns: Font
    func getFont(weight: UIFont.Weight? = nil) -> UIFont {
        let fontWeight = (nil != weight) ? weight! : UIFont.getFontWeight(fontStyle)
        return UIFont(name: self.fontName, size: CGFloat(truncating: self.size)) ?? UIFont.systemFont(ofSize: CGFloat(truncating: self.size), weight: fontWeight)
    }
    
    /// Get color from hex color code
    ///
    /// - Returns: Color
    func getColor() -> UIColor {
        return UIColor.color(hex: colorHex)
    }
}
