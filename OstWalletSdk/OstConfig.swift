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
  private static var useKeychainStoredValues: Bool?
  
  //Defaults
  private static let blockGenerationTimeDefault = 3
  private static let pricePointCurrencySymbolDefault = "USD"
  private static let requestTimeoutDurationDefault = 60
  private static let pinMaxRetryCountDefault = 3
  private static let sessionBufferTimeDefault = Double(3600)
  private static let useSeedPasswordDefault = false
  private static let noOfSessionsOnActivateUserDefault = 1
  private static let useKeychainStoredValuesDefault = false
  
  class func loadConfig(config: [String: Any]?) throws {
    var appConfig: [String: Any]? = config
    if nil == appConfig {
      appConfig = OstBundle.getPlistFileData(fromFile: plistFileName, inBundle: OstBundle.getApplicationBundle())
      if nil == appConfig {
        appConfig = [:]
      }
    }
    
    if let generationTime = getConfigValueForBlockGenerationTime(appConfig: appConfig!) {
      if generationTime is Int {
        let gt = (generationTime as! Int)
        if gt < 1 {
          throw OstError("w_c_lc_gt_1", .invalidBlockGenerationTime)
        }
        blockGenerationTime = gt
      }else {
        throw OstError("w_c_lc_gt_2", .invalidBlockGenerationTime)
      }
    }
    
    if let maxRetryCount = getConfigValueForPinMaxRetryCount(appConfig: appConfig!) {
      if maxRetryCount is Int {
        let mrc = (maxRetryCount as! Int)
        if mrc < 1 {
          throw OstError("w_c_lc_mrc_1", .invalidPinMaxRetryCount)
        }
        pinMaxRetryCount = mrc
      }else {
        throw OstError("w_c_lc_mrc_2", .invalidPinMaxRetryCount)
      }
    }
    
    if let currencySymbol = getConfigValueForPricePointCurrencySymbol(appConfig: appConfig!) {
      if currencySymbol is String {
        let cs = currencySymbol as! String
        if cs.isEmpty {
          throw OstError("w_c_lc_cs_1", .invalidPricePointCurrencySymbol)
        }
        pricePointCurrencySymbol = cs
      }else {
        throw OstError("w_c_lc_cs_2", .invalidPricePointCurrencySymbol)
      }
    }
    
    if let timeoutDuration = getConfigValueForRequestTimeoutDuration(appConfig: appConfig!) {
      if timeoutDuration is Int {
        let td = (timeoutDuration as! Int)
        if td < 1 {
          throw OstError("w_c_lc_td_1", .invalidRequestTimeoutDuration)
        }
        requestTimeoutDuration = td
      }else {
        throw OstError("w_c_lc_td_2", .invalidRequestTimeoutDuration)
      }
    }
    
    if let bufferTime = getConfigValueForSessionBufferTime(appConfig: appConfig!) {
      if bufferTime is NSNumber {
        let bt = (bufferTime as! NSNumber).doubleValue
        if bt < 0 {
          throw OstError("w_c_lc_bt_1", .invalidSessionBufferTime)
        }
        sessionBufferTime = bt
      }else {
        throw OstError("w_c_lc_bt_2", .invalidSessionBufferTime)
      }
    }
    
    let canUseSeedPassword = getConfigValueForUseSeedPassword(appConfig: appConfig!) as? Bool
    useSeedPassword = canUseSeedPassword
    
    let canUseKeychainStoredValues = getConfigValueForUseKeychinStoredValues(appConfig: appConfig!) as? Bool
    useKeychainStoredValues = canUseKeychainStoredValues
    
    if let noOfSessionsOnActivateUserCount = getConfigValueForNoOfSessionsOnActivateUser(appConfig: appConfig!) {
      if noOfSessionsOnActivateUserCount is Int {
        let nosoauc = noOfSessionsOnActivateUserCount as! Int
        if nosoauc < 1
          || nosoauc > 5 {
          throw OstError("w_c_lc_nosoauc_6", .invalidNoOfSessionsOnActivateUser)
        }
        noOfSessionsOnActivateUser = nosoauc
      }else {
        throw OstError("w_c_lc_nosoauc_6", .invalidNoOfSessionsOnActivateUser)
      }
    }
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
  
  class func getConfigValueForUseKeychinStoredValues(appConfig: [String: Any]) -> Any?{
    if let val = appConfig["UseKeychainStoredValues"] {
      return val
    }
    return appConfig["USE_KEYCHAIN_STORED_VALUES"]
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
  
  class func shouldUseKeychainStoredValues() -> Bool {
    return useKeychainStoredValues ?? useKeychainStoredValuesDefault
  }
  
  class func noOfSessionsOnActivateUserCount() -> Int {
    return noOfSessionsOnActivateUser ?? noOfSessionsOnActivateUserDefault
  }
}
