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
 <key>PricePointTokenSymbol</key>
 <string>OST</string>
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
    private static var pricePointTokenSymbol: String?
    private static var pricePointCurrencySymbol: String?
    private static var requestTimeoutDuration: Int?
    private static var pinMaxRetryCount: Int?
    private static var sessionBufferTime: Double?
    private static var useSeedPassword: Bool = false
    
    class func loadConfig() throws {
        do {
            let generationTime = try OstBundle
                .getApplicationPlistContent(
                    for: "BlockGenerationTime",
                    fromFile: plistFileName
                ) as! Int
            blockGenerationTime = generationTime
            
            let tokenSymbol = try OstBundle
                .getApplicationPlistContent(
                    for: "PricePointTokenSymbol",
                    fromFile: plistFileName
                ) as! String
            pricePointTokenSymbol = tokenSymbol
            
            let currencySymbol = try OstBundle
                .getApplicationPlistContent(
                    for: "PricePointCurrencySymbol",
                    fromFile: plistFileName
                ) as! String
            pricePointCurrencySymbol = currencySymbol
            
            let timeoutDuration = try OstBundle
                .getApplicationPlistContent(
                    for: "RequestTimeoutDuration",
                    fromFile: plistFileName
                ) as! Int
            requestTimeoutDuration = timeoutDuration
            
            let maxRetryCount = try OstBundle
                .getApplicationPlistContent(
                    for: "PinMaxRetryCount",
                    fromFile: plistFileName
                ) as! Int
            pinMaxRetryCount = maxRetryCount
            
            let bufferTime = try OstBundle
                .getApplicationPlistContent(
                    for: "SessionBufferTime",
                    fromFile: plistFileName
                ) as! Double
            sessionBufferTime = bufferTime
            
            useSeedPassword = try OstBundle
                .getApplicationPlistContent(
                    for: "UseSeedPassword",
                    fromFile: plistFileName
                ) as! Bool
            
        } catch {
            throw OstError("oc_lc_1", .failedToReadOstSdkPlist)
        }
    }

    //MARK: - Getter
    class func getBlockGenerationTime() -> Int {
        return blockGenerationTime!
    }

    class func getPricePointTokenSymbol() -> String {
        return pricePointTokenSymbol!
    }

    class func getPricePointCurrencySymbol() -> String {
        return pricePointCurrencySymbol!
    }

    class func getRequestTimeoutDuration() -> Int {
        return requestTimeoutDuration!
    }

    class func getPinMaxRetryCount() -> Int {
        return pinMaxRetryCount!
    }

    class func getSessionBufferTime() -> Double {
        return sessionBufferTime!
    }
    
    class func shouldUseSeedPassword() -> Bool {
        return useSeedPassword
    }
    
}
