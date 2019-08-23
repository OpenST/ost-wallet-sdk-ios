/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

/*
 Following is the expected plist example
 
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 <key>BlockGenerationTime</key>
 <integer>3</integer>
 <key>PricePointCurrencySymbol</key>
 <string>USD</string>
 <key>RequestTimeoutDuration</key>
 <integer>6</integer>
 <key>PinMaxRetryCount</key>
 <integer>3</integer>
 <key>SessionBufferTime</key>
 <integer>3600</integer>
 <key>UseSeedPassword</key>
 <true/>
 </dict>
 </plist>
 */

class OstConfig {
    
    private static let plistFileName = "OstWalletSdk"
    private static var blockGenerationTime: Int?
    private static var pricePointCurrencySymbol: String?
    private static var requestTimeoutDuration: Int?
    private static var pinMaxRetryCount: Int?
    private static var sessionBufferTime: Double?
    private static var useSeedPassword: Bool?
    private static var noOfSessionsOnActivateUser: Int?
    
    //Defaults
    private static let blockGenerationTimeDefault = 3
    private static let pricePointCurrencySymbolDefault = "USD"
    private static let requestTimeoutDurationDefault = 60
    private static let pinMaxRetryCountDefault = 3
    private static let sessionBufferTimeDefault = Double(3600)
    private static let useSeedPasswordDefault = false
    private static let noOfSessionsOnActivateUserDefault = 1
    
    
    class func loadConfig(config: [String: Any]?) throws {
        var appConfig: [String: Any]? = config
        if nil == appConfig {
            appConfig = OstBundle.getPlistFileData(fromFile: plistFileName, inBundle: OstBundle.getApplicationBundle())
            if nil == appConfig {
                appConfig = [:]
            }
        }
        
        let generationTime = getConfigValueForBlockGenerationTime(appConfig: appConfig!) as? Int
        if nil == generationTime || generationTime! < 1 {
            throw OstError("w_c_lc_1", .invalidBlockGenerationTime)
        }
        blockGenerationTime = generationTime
        
        let maxRetryCount = getConfigValueForPinMaxRetryCount(appConfig: appConfig!) as? Int
        if nil == maxRetryCount || maxRetryCount! < 1 {
            throw OstError("w_c_lc_2", .invalidPinMaxRetryCount)
        }
        pinMaxRetryCount = maxRetryCount
        
        let currencySymbol = getConfigValueForPricePointCurrencySymbol(appConfig: appConfig!) as? String
        if nil == currencySymbol || currencySymbol!.isEmpty {
            throw OstError("w_c_lc_3", .invalidPricePointCurrencySymbol)
        }
        pricePointCurrencySymbol = currencySymbol
        
        let timeoutDuration = getConfigValueForRequestTimeoutDuration(appConfig: appConfig!) as? Int
        if nil == timeoutDuration || timeoutDuration! < 1 {
            throw OstError("w_c_lc_4", .invalidRequestTimeoutDuration)
        }
        requestTimeoutDuration = timeoutDuration
       
        let bufferTime = getConfigValueForSessionBufferTime(appConfig: appConfig!) as? Double
        if nil == bufferTime || bufferTime! < 0 {
            throw OstError("w_c_lc_5", .invalidSessionBufferTime)
        }
        sessionBufferTime = bufferTime
        
        let canUseSeedPassword = getConfigValueForUseSeedPassword(appConfig: appConfig!) as? Bool
        useSeedPassword = canUseSeedPassword
        
        let noOfSessionsOnActivateUserCount = getConfigValueForNoOfSessionsOnActivateUser(appConfig: appConfig!) as? Int
        if nil == noOfSessionsOnActivateUserCount
            || noOfSessionsOnActivateUserCount! < 1
            || noOfSessionsOnActivateUserCount! > 5 {
            throw OstError("w_c_lc_6", .invalidNoOfSessionsOnActivateUser)
        }
        noOfSessionsOnActivateUser = noOfSessionsOnActivateUserCount
    }
    
    
    //MARK: - Getter For Config
    class func getConfigValueForBlockGenerationTime(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["BlockGenerationTime"] {
            return val
        }
        return appConfig["BLOCK_GENERATION_TIME"]
    }
    
    class func getConfigValueForPinMaxRetryCount(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["PinMaxRetryCount"] {
            return val
        }
        return appConfig["PIN_MAX_RETRY_COUNT"]
    }
    
    class func getConfigValueForPricePointCurrencySymbol(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["PricePointCurrencySymbol"] {
            return val
        }
        return appConfig["PRICE_POINT_CURRENCY_SYMBOL"]
    }
    
    class func getConfigValueForRequestTimeoutDuration(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["RequestTimeoutDuration"] {
            return val
        }
        return appConfig["REQUEST_TIMEOUT_DURATION"]
    }
    
    class func getConfigValueForSessionBufferTime(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["SessionBufferTime"] {
            return val
        }
        return appConfig["SESSION_BUFFER_TIME"]
    }
    
    class func getConfigValueForUseSeedPassword(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["UseSeedPassword"] {
            return val
        }
        return appConfig["USE_SEED_PASSWORD"]
    }
    
    class func getConfigValueForNoOfSessionsOnActivateUser(appConfig: [String: Any]) -> Any?{
        if let val = appConfig["NoOfSessionsOnActivateUser"] {
            return val
        }
        return appConfig["NO_OF_SESSIONS_ON_ACTIVATE_USER"]
    }
    
    //MARK: - Getter
    class func getBlockGenerationTime() -> Int {
        return blockGenerationTime ?? blockGenerationTimeDefault
    }
    
    class func getPricePointCurrencySymbol() -> String {
        return pricePointCurrencySymbol?.uppercased() ?? pricePointCurrencySymbolDefault.uppercased()
    }
    
    class func getRequestTimeoutDuration() -> Int {
        return requestTimeoutDuration ?? requestTimeoutDurationDefault
    }
    
    class func getPinMaxRetryCount() -> Int {
        return pinMaxRetryCount ?? pinMaxRetryCountDefault
    }
    
    class func getSessionBufferTime() -> Double {
        return sessionBufferTime ?? sessionBufferTimeDefault
    }
    
    class func shouldUseSeedPassword() -> Bool {
        return useSeedPassword ?? useSeedPasswordDefault
    }
    
    class func noOfSessionsOnActivateUserCount() -> Int {
        return noOfSessionsOnActivateUser ?? noOfSessionsOnActivateUserDefault
    }
}
