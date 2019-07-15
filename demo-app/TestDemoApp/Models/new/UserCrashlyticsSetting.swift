/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import Fabric
import Crashlytics

class UserCrashlyticsSetting {
    static let shared = UserCrashlyticsSetting()
    
    private var isFabricRunning: Bool = false
    var isUserOptInForFabric: Bool? = nil
    var isRequestInProgress: Bool = false
    
    private var completionHandler: (() -> Void? )? = nil
    
    private var progressIndicator: OstProgressIndicator? = nil
    
    
    func fetchPreferenceFromServer(completion: (() -> Void)?) {
        let deviceAddress = CurrentUserModel.getInstance.currentDevice!.address!
        let params: [String: Any] = ["device_address": deviceAddress]
        UserAPI.getCrashlyticsPreference(
            userId: CurrentUserModel.getInstance.appUserId!,
            params: params,
            onSuccess: {[weak self] (data) in
                self?.assignPreferenceIfPresent(data)
                completion?()
            },
            onFailure: { (error) in
                completion?()
        })
    }
    
    func assignPreferenceIfPresent(_ data: [String: Any]?) {
        guard let isOptIn: Bool = data?["preference"] as? Bool else {
            return
        }
        
        isUserOptInForFabric = isOptIn
        initiateTwitterCrashlyticsIfRquired()
    }
    
    
    func verifyUserCrashlyticsPreferenceIfRequired() {
        if isUserOptInForFabric == nil && !isRequestInProgress {
            
            let deviceAddress = CurrentUserModel.getInstance.currentDevice!.address!
            
            let params: [String: Any] = ["device_address": deviceAddress]
            isRequestInProgress = true
            UserAPI.getCrashlyticsPreference(
                userId: CurrentUserModel.getInstance.appUserId!,
                params: params,
                onSuccess: {[weak self] (data) in
                    self?.isRequestInProgress = false
                    self?.onSuccessForCrashlyticsPreference(data)
            },
                onFailure: {[weak self] (error) in
                    self?.isRequestInProgress = false
            })
        }
    }
    
    func onSuccessForCrashlyticsPreference(_ data: [String: Any]?) {
        
        guard let isOptIn: Bool = data?["preference"] as? Bool else {
            askForCrashlyticsPermission()
            return
        }

        isUserOptInForFabric = isOptIn
        initiateTwitterCrashlyticsIfRquired()
        
        // fabric running and user opted out
        if isFabricRunning && !isOptIn {
            showRelauchAlert()
        }else {
            //showSuccessAlert()
            progressIndicator?.hide()
            progressIndicator = nil
        }
        
        completionHandler?()
    }
    
    func onFailureForCrashlyticsPreference(_ data: [String: Any]?) {
        showFailureAlert()
        completionHandler?()
    }
    
    func initiateTwitterCrashlyticsIfRquired() {
        if isOptInForCrashReport() {
            Fabric.with([Crashlytics.self])
            isFabricRunning = true
        }
    }
    
    func askForCrashlyticsPermission() {
        let alert = UIAlertController(title: "Crash Reporting",
                                      message: "Would you like to share crash reports with OST to help improve the app?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Opt in", style: .cancel, handler: {[weak self] (_) in
            self?.updateCrashReportPreference(true)
        }))
        alert.addAction(UIAlertAction(title: "Opt out", style: .default, handler: {[weak self] (_) in
            self?.updateCrashReportPreference(false)
        }))
        alert.show()
    }
    
    func updateCrashReportPreference(_ preference: Bool, completion: (() -> Void)? = nil) {
        completionHandler = completion
        progressIndicator?.hide()
        progressIndicator = nil
        
        let deviceAddress = CurrentUserModel.getInstance.currentDevice!.address!
        progressIndicator = OstProgressIndicator(textCode: .unknown)
        progressIndicator?.show()
        
        let params: [String: Any] = ["preference": preference, "device_address": deviceAddress]
        
        UserAPI.updateCrashlyticsPreference(
            userId: CurrentUserModel.getInstance.appUserId!,
            params: params,
            onSuccess: {[weak self] (data) in
                self?.onSuccessForCrashlyticsPreference(data)
            }, onFailure: {[weak self] (error) in
                self?.onFailureForCrashlyticsPreference(error)
        })
    }
    
    func showRelauchAlert() {
        if progressIndicator == nil {
            progressIndicator = OstProgressIndicator(progressText: "")
        }
        let isOptIn = isOptInForCrashReport()
        let alertTitleText = isOptIn ?  "Opt in to crash reporting" : "Opt out from crash reporting"
        
        progressIndicator?.showSuccessAlert(withTitle: alertTitleText,
                                            message: "For the changes to take effect, please exit the app and re-launch it",
                                            duration: 0,
                                            actionButtonTitle: "Ok")
    }
    
    func showFailureAlert() {
        if progressIndicator == nil {
            progressIndicator = OstProgressIndicator(progressText: "")
        }
        
        progressIndicator?.showFailureAlert(withTitle: "",
                                            message: "Sorry, we could not save your preferences. Please try  changing them on the Settings tab",
                                            duration: 3,
                                            onCompletion: nil)
    }
    
    func showSuccessAlert() {
        let isOptIn = isOptInForCrashReport()
        let alertTitleText: String
        if !isOptIn {
            alertTitleText = "Your preference to opt out from crash reporting is saved successfully"
        }else {
            alertTitleText = "Your preference to opt in to crash reporting is saved successfully"
        }
        
        progressIndicator?.showSuccessAlert(withTitle: "",
                                            message: "\(alertTitleText) applied successfaully.")
    }
    
    func getCrashReportPreference() -> Bool? {
        return isUserOptInForFabric
    }
    
    func isOptInForCrashReport() -> Bool {
        let isOptIn = getCrashReportPreference()
        return isOptIn ?? false
    }
}
