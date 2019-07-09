/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class UserSetting {
    static let shared = UserSetting()
    
    private let isOptInForCrashReportKey: String = "is_opt_in_for_crash_report"
    
    func getCrashReportPreference() -> Bool {
        let crashReportPreference = UserDefaults.standard.bool(forKey: isOptInForCrashReportKey)
        return crashReportPreference
    }
    
    func updateCrashReportPreference() {
        let crashReportPreference = getCrashReportPreference()
        UserDefaults.standard.set(!crashReportPreference, forKey: isOptInForCrashReportKey)
    }
    
    func isOptInForCrashReport() -> Bool {
        let isOptIn = getCrashReportPreference()
        return isOptIn
    }
}
