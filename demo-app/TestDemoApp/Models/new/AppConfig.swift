/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class AppConfig: NSObject {
    static let appThemeConfig: [String: Any] = [
        "nav_bar_logo_image": [
            "asset_name": "ostLogoBlue"
        ],
        
        "h1": ["size": 20,
               "font": "Lato-Bold",
               "color": "#438bad",
               "font_style": "semi_bold",
               "alignment": "left"
        ],
        
        "h2": ["size": 17,
               "font": "SFProDisplay",
               "color": "#666666",
               "font_style": "medium",
               "alignment": "center"
        ],
        
        "h3": ["size": 15,
               "font": "SFProDisplay",
               "color": "#888888",
               "font_style": "regular",
               "alignment": "center"
        ],
        
        "h4": ["size": 12,
               "font": "SFProDisplay",
               "color": "#888888",
               "font_style": "regular",
               "alignment": "center"
        ],
        
        "c1": ["size": 14,
               "font": "SFProDisplay",
               "color": "#484848",
               "font_style": "bold",
               "alignment": "left"
        ],
        
        "c2": ["size": 12,
               "font": "SFProDisplay",
               "color": "#6F6F6F",
               "font_style": "regular",
               "alignment": "left"
        ],
        
        "b1": [
            "size": 25,
            "font": "SFProDisplay",
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_style": "medium"
        ],
        
        "b2": [
            "size": 20,
            "font": "SFProDisplay",
            "color": "#438bad",
            "background_color": "#ffffff",
            "font_style": "medium"
        ],
        
        "b3": [
            "size": 15,
            "font": "SFProDisplay",
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_style": "medium"
        ],
        
        "b4": [
            "size": 12,
            "font": "SFProDisplay",
            "color": "#438bad",
            "background_color": "#ffffff",
            "font_style": "medium"
        ],
        
        "navigation_bar": [
            "tint_color": "#ffffff"
        ],
        
        "icons": [
            "close": [
                "tint_color": "#438bad"
            ],
            "back":[
                "tint_color": "#438bad"
            ]
        ]
    ]
    
    static let appContentConfig: [String: Any] = [
        "activate_user": [
            "create_pin": [
                "terms_and_condition_url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"
            ],
            "confirm_pin": [
                "terms_and_condition_url": "https://ost.com/terms"
            ]
        ]
    ]
}
