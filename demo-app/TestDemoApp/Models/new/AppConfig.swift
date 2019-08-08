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
        ],
        
        "pin_input": [
            "empty_color": "#c7c7cc",
            "filled_color": "#438bad"
        ]
    ]
    
    static let appContentConfig: [String: Any] = [
        "activate_user": [
            "create_pin": [
                "title_label": [
                    "text": "Create Pin"
                ],
                "lead_label": [
                    "text": "Add a 6-digit PIN to secure your wallet"
                ],
                "info_label":[
                    "text":  "PIN helps you recover your wallet if the phone is lost or stolen"
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
                    "text": "If you forget your PIN, you cannot recover your wallet"
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
        ],
        
        "add_session": [
            "get_pin": [
                "title_label": [
                    "text": "Create Session"
                ],
                "lead_label": [
                    "text": "Add a 6-digit PIN to secure your wallet."
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "initiate_recovery": [
            "device_list": [
                "title_label": [
                    "text": "Device Recovery"
                ],
                "lead_label": [
                    "text": "This is an authorized device, recovery applies only to cases where a user has no authorized device"
                ],
                "cell": [
                    "action_button": [
                        "text": "Start Recovery"
                    ]
                ]
            ],
            "get_pin": [
                "title_label": [
                    "text": "Recover Access to Your Wallet"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN to recover access to your wallet"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "abort_recovery": [
            "get_pin": [
                "title_label": [
                    "text": "Abort Recovery"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN to abort recovery"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "revoke_device": [
            "device_list": [
                "title_label": [
                    "text": "Recover Access to Your Wallet"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN to recover access to your wallet"
                ],
                "cell": [
                    "action_button": [
                        "text": "Revoke Device"
                    ]
                ]
            ],
            
            "get_pin": [
                "title_label": [
                    "text": "Revoke Access to Your Wallet"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "biometric_preference": [
            "get_pin": [
                "title_label": [
                    "text": "Update Biometric Preference"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN to update biometric preference"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "reset_pin": [
            "get_pin": [
                "title_label": [
                    "text": "Enter Old Pin"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ],
            
            "set_new_pin": [
                "title_label": [
                    "text": "New Pin"
                ],
                "lead_label": [
                    "text": "Enter your new 6-digit PIN."
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ],
            
            "confirm_new_pin": [
                "title_label": [
                    "text": "Confirm New Pin"
                ],
                "lead_label": [
                    "text": "Enter your new 6-digit PIN."
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "logout_all_sessions": [
            "get_pin": [
                "title_label": [
                    "text": "Logout all sessions"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ]
        ],
        
        "view_mnemonics": [
            "get_pin": [
                "title_label": [
                    "text": "Logout all sessions"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ],
            
            "show_mnemonics": [
                "title_label": [
                    "text": "Write these words down"
                ],
                "lead_label": [
                    "text": "Your 12-word Mnemonic Phrase"
                ],
                "terms_and_condition_label": [
                    "text": "You can write the phrases down in a piece of paper or save in a password manager. Don’t email them or screenshot them. The order of words are important too."
                ]
            ]
        ],
        
        "add_device_with_qr": [
            "get_pin": [
                "title_label": [
                    "text": "Add device with QR"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ],
            
            "verify_device_address": [
                "title_label": [
                    "text": "Add device with QR"
                ],
                "lead_label": [
                    "text": "Please verify device address which is going to be authorized."
                ],
                "action_button": [
                    "text": "Authorize Device"
                ]
            ]
        ],
        
        "add_current_device_with_mnemonics": [
            "get_pin": [
                "title_label": [
                    "text": "Add device with QR"
                ],
                "lead_label": [
                    "text": "Enter your 6-digit PIN"
                ],
                "info_label":[
                    "text":  ""
                ],
                "terms_and_condition_label": [
                    "text": ""
                ]
            ],
            
            "provide_mnemonics": [
                "title_label": [
                    "text": "Add device with QR"
                ],
                "lead_label": [
                    "text": ""
                ],
                "action_button": [
                    "text": "Authorize Device"
                ]
            ]
        ],
        
        "execute_transaction_via_qr": [
            "verify_transaction": [
                "title_label": [
                    "text": "Verify transction"
                ],
                "lead_label": [
                    "text": ""
                ],
                "action_button": [
                    "text": "Execute Transaction"
                ]
            ]
        ]
    ]
}
