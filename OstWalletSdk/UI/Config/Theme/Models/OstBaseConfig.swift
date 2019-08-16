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
    let fontWeight: String
    
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - config: Config
    init(config: [String: Any]) {
        
        self.fontName = config["font"] as? String ?? ""
        self.size = config["size"] as! NSNumber
        self.colorHex = config["color"] as! String
        self.fontWeight = config["system_font_weight"] as! String
    }
    
    /// Get font for provided config
    ///
    /// - Parameter weight: Font weight
    /// - Returns: Font
    func getFont(font: String? = nil, weight: UIFont.Weight? = nil) -> UIFont {
        
        let fontWeightVal = (nil != weight) ? weight! : UIFont.getFontWeight(fontWeight)
        
        var font: UIFont? = UIFont(name: font ?? self.fontName, size: CGFloat(truncating: self.size))
        
        if nil == font {
            font = UIFont.systemFont(ofSize: CGFloat(truncating: self.size), weight: fontWeightVal)
        }
        
        return font!
    }
    
    /// Get color from hex color code
    ///
    /// - Returns: Color
    func getColor() -> UIColor {
        return UIColor.color(hex: colorHex)
    }
}
