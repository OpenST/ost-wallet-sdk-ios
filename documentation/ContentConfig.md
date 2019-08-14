# Content Config

## Config Structure
* First level of json is `workflow`.
* Value for workflow are the `pages` which wokflow contains.
* Customizable `Components` are present under key pages.
* Componet contaisn customizable `property`.

```json
{
    "WORKFLOW": {
        "PAGE": {
            "COMPONENT": {
                "PROPERTY": <VALUE>
            }
        }
    }
}
```

## Config Info
OstWalletUI supports 8 workflows:
* actiavte user
* create session
* get device mnemonis
* revoke device
* reset pin
* initiate device recovery
* abort device recovery
* update biometric preference

### Page
Properties which can be editable from config are:

**Pin View**
* title_label
* lead_label
* info_label
* terms_and_condition_label

**Device List**
* title_label
* info_label
* action_button_text: Set value for key `cell -> action_button -> text` 

**Show Mnemonics**
* title_label
* info_label
* bottom_label

### Component


## Content JSON

```json
{
    "activate_user": {
        "create_pin": {
            "title_label": {
                "text": "Create Pin"
            },
            "lead_label": {
                "text": "Add a 6-digit PIN to secure your wallet"
            },
            "info_label":{
                "text":  "PIN helps you recover your wallet if the phone is lost or stolen"
            },
            "terms_and_condition_label": {
                "text": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. {{terms_and_condition}}"
            },
            "placeholders": {
                "terms_and_condition": {
                    "url": "https://ost.com/terms",
                    "text": "T&C Apply",
                    "color": "#0076FF"
                }
            }        
        },
        "confirm_pin": {
            "title_label": {
                "text": "Confirm PIN"
            },
            "lead_label": {
                "text": "If you forget your PIN, you cannot recover your wallet"
            },  
            "info_label":{
                "text":  "So please be sure to remember it"
            },
            "terms_and_condition_label": {
                "text": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. {{terms_and_condition}}"
            },
            "placeholders": {
                "terms_and_condition": {
                    "url": "https://ost.com/terms",
                    "text": "T&C Apply",
                    "color": "#0076FF"
                }
            }
        }
    },

    "add_session": {
        "get_pin": {
            "title_label": {
                "text": "Create Session"
            },
            "lead_label": {
                "text": "Add a 6-digit PIN to secure your wallet"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "initiate_recovery": {
        "device_list": {
            "title_label": {
                "text": "Device Recovery"
            },
            "info_label": {
                "text": "This is a list of all the devices that are authorized to access your wallet"
            },
            "cell": {
                "action_button": {
                    "text": "Start Recovery"
                }
            }
        },
        "get_pin": {
            "title_label": {
                "text": "Recover Access to Your Wallet"
            },
            "lead_label": {
                "text": "Enter your 6-digit PIN to recover access to your wallet"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "abort_recovery": {
        "get_pin": {
            "title_label": {
                "text": "Abort Recovery"
            },
            "lead_label": {
                "text": "Enter your 6-digit PIN to abort recovery"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "revoke_device": {
        "device_list": {
            "title_label": {
                "text": "Revoke Device"
            },
            "info_label": {
                "text": "This is a list of all the devices that are authorized to access your wallet"
            },
            "cell": {
                "action_button": {
                    "text": "Revoke Device"
                }
            }
        },

        "get_pin": {
            "title_label": {
                "text": "Revoke Device"
            },
            "lead_label": {
                "text": "Enter your 6-digit PIN to authorize your action"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "biometric_preference": {
        "get_pin": {
            "title_label": {
                "text": "Biometric Preference"
            },
            "lead_label": {
                "text": "Enter your 6-digit PIN to authorize your action"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "reset_pin": {
        "get_pin": {
            "title_label": {
                "text": "Enter Current PIN"
            },
            "lead_label": {
                "text": "Enter your current 6-digit PIN"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        },

        "set_new_pin": {
            "title_label": {
                "text": "Add New Pin"
            },
            "lead_label": {
                "text": "Add a 6-digit PIN to secure your wallet"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        },

        "confirm_new_pin": {
            "title_label": {
                "text": "Confirm New Pin"
            },
            "lead_label": {
                "text": "If you forget your PIN, you cannot recover your wallet"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        }
    },

    "view_mnemonics": {
        "get_pin": {
            "title_label": {
                "text": "View Mnemonics"
            },
            "lead_label": {
                "text": "Enter your 6-digit PIN to authorize your action"
            },
            "info_label":{
                "text":  ""
            },
            "terms_and_condition_label": {
                "text": ""
            }
        },

        "show_mnemonics": {
            "title_label": {
                "text": "View Mnemonics"
            },
            "info_label": {
                "text": "Write down your 12-word mnemonic phrase and store them securely"
            },
            "bottom_label": {
                "text": "You can write the phrases down in a piece of paper or save in a password manager. Don’t email them or screenshot them. The order of words are important too."
            }
        }
    }
}
```
