//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstPinVCConfig: NSObject {
    
    @objc enum PinVCType: Int {
        case
        CreatePin,
        ConfirmPin,
        DeviceRecovery
    }
    
    let titleText: String?
    let leadLabelText: String?
    let infoLabelText: String?
    let tcLabelText: String?

    init(titleText: String?,
         leadLabelText: String?,
         infoLabelText: String?,
         tcLabelText: String?) {
        
        self.titleText = titleText
        self.leadLabelText = leadLabelText
        self.infoLabelText = infoLabelText
        self.tcLabelText = tcLabelText
    }
    
    
    class func getCreatePinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Create PIN",
                              leadLabelText: "Add a 6-digit PIN to secure your wallet",
                              infoLabelText: "PIN helps to recover your wallet if your phone is lost or stolen",
                              tcLabelText: "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet.")
    }
    
    class func getConfirmPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Confirm PIN",
                              leadLabelText: "If you forget your PIN, you cannot recover your wallet",
                              infoLabelText: "So please be sure to remember it",
                              tcLabelText: "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet.")
    }
    
    class func getRecoveryAccessPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Recover Access to Your Wallet",
                              leadLabelText: "Enter your 6-digit PIN to recover access to your wallet",
                              infoLabelText: nil,
                              tcLabelText: nil)
    }
    
    class func getAbortRecoveryPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Abort Recovery",
                              leadLabelText: "Enter your 6-digit PIN to abort recovery",
                              infoLabelText: nil,
                              tcLabelText: nil)
    }

    class func getAddSessinoPinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Add Session",
                              leadLabelText: "Enter your 6-digit PIN to add session",
                              infoLabelText: nil,
                              tcLabelText:  nil)
    }
    
    class func getUpdateBiometricPreferencePinVCConfig() -> OstPinVCConfig {
        return OstPinVCConfig(titleText: "Update Biometric Preference",
                              leadLabelText: "Enter your 6-digit PIN to upadte biometric preference",
                              infoLabelText: nil,
                              tcLabelText:  nil)
    }
}
