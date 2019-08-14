# OstWalletUI Content Config
App developers can configure the text shown on various views displayed by OstWalletUI.
To configure the content, the sdk needs to be provided with `Dictionary`.

## Dictionary Data Structure
Here is the small sample `json` representation of the configuration.
```json
{
    "activate_user": {
        "create_pin": {
            "title_label": {
                "text": "Activate Your Wallet"
            }
        }
    }
}
```

In the above example:
* The first-level key `activate_user` corresponds to `Activate User` workflow.
* The second-level key `create_pin` corresponds to `Create Pin` view.
* The third-level key `title_label` corresponds to label that displays the title of the view.
* The fourth-level key `text` is corresponds to diplay text to the title label.

## Supported Workflows
OstWalletUI supports 8 workflows

| Configuration Keys   | Workflows                   |
| -------------------- |:---------------------------:|
| activate_user        | Activate User               |
| add_session          | Add Session                 |
| initiate_recovery    | Initialize Recovery         |
| abort_recovery       | Abort Device Recovery       |
| revoke_device        | Revoke Device               |
| biometric_preference | Update Biometric Preference |
| reset_pin            | Reset a User's PIN          |
| view_mnemonics       | Get Mnemonic Phrase         |

## Supported Views
### Activate User Workflow Views

| Configuration Keys   | Views                                                       |
| -------------------- | ----------------------------------------------------------- |
| create_pin           | Create Pin View where user sets the pin for first time      |
| confirm_pin          | Confirm Pin View where user confirms the pin again          |

### Add Session Views

| Configuration Keys   | Views                                                      |
| -------------------- | ---------------------------------------------------------- |
| get_pin              | Get Pin View where user provides pin for authentication    |

### Initialize Recovery Views

| Configuration Keys   | Views                                                       |
| -------------------- | ----------------------------------------------------------- |
| device_list          | Displays list of authorized devices for user to choose from |
| get_pin              | Get Pin View where user provides pin for authentication     |


### Abort Device Recovery Views

| Configuration Keys   | Views                                                      |
| -------------------- | ---------------------------------------------------------- |
| get_pin              | Get Pin View where user provides pin for authentication    |

### Revoke Device Views

| Configuration Keys   | Views                                                       |
| -------------------- | ----------------------------------------------------------- |
| device_list          | Displays list of authorized devices for user to choose from |
| get_pin              | Get Pin View where user provides pin for authentication     |

### Update Biometric Preferences Views

| Configuration Keys   | Views                                                      |
| -------------------- | ---------------------------------------------------------- |
| get_pin              | Get Pin View where user provides pin for authentication    |

### Reset a User's PIN Views

| Configuration Keys   | Views                                                      |
| -------------------- | ---------------------------------------------------------- |
| get_pin              | Get Pin View where user provides current pin               |
| set_new_pin          | View where user sets the new pin                           |
| confirm_new_pin      | Confirm Pin View where user confirms the new pin again     |

### Get Mnemonic Phrase Views

| Configuration Keys   | Views                                                      |
| -------------------- | ---------------------------------------------------------- |
| get_pin              | Get Pin View where user provides pin for authentication    |

## Supported Elements in PIN Input Views
Here, we refer follwing views as 'Pin Input' views:
* create_pin
* confirm_pin
* get_pin
* set_new_pin
* confirm_new_pin


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
