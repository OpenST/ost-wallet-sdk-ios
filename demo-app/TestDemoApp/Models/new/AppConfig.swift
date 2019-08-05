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
               "font": "SFProDisplay",
               "color": "#438bad",
               "font_style": "semi_bold",
               "alignment": "center"
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
                "title_label": [
                    "text": "Create Pin"
                ],
                "lead_label": [
                    "text": "Add a 6-digit PIN to secure your wallet."
                ],
                "info_label":[
                    "text":  "(PIN helps you recover your wallet if the phone is lost or stolen)"
                ],
                "terms_and_condition_label": [
                    "text": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. {{terms_and_condition}}"
                ],
                "placeholders": [
                    "terms_and_condition": [
                        "url": "https://ost.com/terms",
                        "text": "T&C Apply",
                        "font": "SFProDisplay",
                        "color": "#0076FF"
                    ]
                ]
            ],
            "confirm_pin": [
                "title_label": [
                    "text": "Confirm PIN"
                ],
                "lead_label": [
                    "text": "If you forget your PIN, you cannot recover your wallet."
                ],
                "info_label":[
                    "text":  "(So please be sure to remember it)"
                ],
                "terms_and_condition_label": [
                    "text": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. {{terms_and_condition}}"
                ],
                "placeholders": [
                    "terms_and_condition": [
                        "url": "https://ost.com/terms",
                        "text": "T&C Apply",
                        "font": "SFProDisplay",
                        "color": "#0076FF"
                    ]
                ]
            ]
        ]
    ]
}
