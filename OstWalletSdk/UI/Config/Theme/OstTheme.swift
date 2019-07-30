//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstTheme: NSObject {
    private static var instance: OstTheme? = nil
    var themeConfig: [String: Any] = [:]
    
    /// Get instance for OstTheme
    ///
    /// - Returns: OstTheme
    class func getInstance() -> OstTheme {
        var instance = OstTheme.instance
        if nil == instance {
            instance = OstTheme(themeConfig: [:])
        }
        return instance!
    }
    
    /// Initialize
    ///
    /// - Parameter themeConfig: Theme config
    init(themeConfig: [String: Any]) {
        self.themeConfig = themeConfig
        super.init()
        OstTheme.instance = self
    }
    
    
    /// Get `h1` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH1Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h1"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h1"] as! [String: Any])
    }
    
    /// Get `h2` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH2Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h2"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h2"] as! [String: Any])
    }
    
    /// Get `h3` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH3Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h3"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h3"] as! [String: Any])
    }
    
    /// Get `h4` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH4Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h4"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["h4"] as! [String: Any])
    }
    
    /// Get `c1` theme config
    ///
    /// - Returns: OstLabelConfig
    func getC1Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["c1"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["c1"] as! [String: Any])
    }
    
    /// Get `c2` theme config
    ///
    /// - Returns: OstLabelConfig
    func getC2Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["c2"] as? [String: Any],
                              defaultConfig: OstDefaultTheme.theme["c2"] as! [String: Any])
    }
    
    /// Get `b1` theme config
    ///
    /// - Returns: OstButtonConfig
    func getB1Config() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["b1"] as? [String: Any],
                                defaultConfig: OstDefaultTheme.theme["b1"] as! [String: Any])
    }
    
    /// Get `b2` theme config
    ///
    /// - Returns: OstButtonConfig
    func getB2Config() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["b2"] as? [String: Any],
                                defaultConfig: OstDefaultTheme.theme["b2"] as! [String: Any])
    }
}


@objc class OstDefaultTheme: NSObject {
    static let theme: [String: Any] = [
        "h1": ["size": 20,
               "font": "SFProDisplay",
               "color": "#438bad",
               "font_style": "semi_bold"
        ],
        
        "h2": ["size": 17,
               "font": "SFProDisplay",
               "color": "#666666",
               "font_style": "medium"
        ],
        
        "h3": ["size": 15,
               "font": "SFProDisplay",
               "color": "#888888",
               "font_style": "regular"
        ],
        
        "h4": ["size": 12,
               "font": "SFProDisplay",
               "color": "#888888",
               "font_style": "regular"
        ],
        
        "c1": ["size": 14,
               "font": "SFProDisplay",
               "color": "#484848",
               "font_style": "bold"
        ],
        
        "c2": ["size": 12,
               "font": "SFProDisplay",
               "color": "#6F6F6F",
               "font_style": "regular"
        ],
        
        "b1": [
            "size": 17,
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_style": "medium"
        ],
        
        "b2": [
            "size": 17,
            "color": "#438bad",
            "background_color": "#ffffff",
            "font_style": "semi_bold"
        ],
        
        "b3": [
            "size": 12,
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_style": "medium"
        ],
        
        "b4": [
            "size": 12,
            "color": "#438bad",
            "background_color": "#ffffff",
            "font_style": "medium"
        ]
    ]
}
