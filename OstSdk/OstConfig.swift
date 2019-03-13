//
//  OstConfig.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 13/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/*
 Following is the expected plist example
 
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 <key>BLOCK_GENERATION_TIME</key>
 <integer>3</integer>
 <key>PRICE_POINT_TOKEN_SYMBOL</key>
 <string>OST</string>
 <key>PRICE_POINT_CURRENCY_SYMBOL</key>
 <string>USD</string>
 <key>REQUEST_TIMEOUT_DURATION</key>
 <integer>6</integer>
 <key>PIN_MAX_RETRY_COUNT</key>
 <integer>3</integer>
 <key>SESSION_BUFFER_TIME</key>
 <integer>3600</integer>
 </dict>
 </plist>
 */

class OstConfig {
 
    private static let plistFileName = "OstSdk"
    private static var blockGenerationTime: Int?
    private static var pricePointTokenSymbol: String?
    private static var pricePointCurrencySymbol: String?
    private static var requestTimeoutDuration: Int?
    private static var pinMaxRetryCount: Int?
    private static var sessionBufferTime: Double?
    
    class func loadConfig() throws {
        do {
            let generationTime = try OstBundle
                .getApplicationPlistContent(
                    for: "BLOCK_GENERATION_TIME",
                    fromFile: plistFileName
                ) as! Int
            blockGenerationTime = generationTime
            
            let tokenSymbol = try OstBundle
                .getApplicationPlistContent(
                    for: "PRICE_POINT_TOKEN_SYMBOL",
                    fromFile: plistFileName
                ) as! String
            pricePointTokenSymbol = tokenSymbol
            
            let currencySymbol = try OstBundle
                .getApplicationPlistContent(
                    for: "PRICE_POINT_CURRENCY_SYMBOL",
                    fromFile: plistFileName
                ) as! String
            pricePointCurrencySymbol = currencySymbol
            
            let timeoutDuration = try OstBundle
                .getApplicationPlistContent(
                    for: "REQUEST_TIMEOUT_DURATION",
                    fromFile: plistFileName
                ) as! Int
            requestTimeoutDuration = timeoutDuration
            
            let maxRetryCount = try OstBundle
                .getApplicationPlistContent(
                    for: "PIN_MAX_RETRY_COUNT",
                    fromFile: plistFileName
                ) as! Int
            pinMaxRetryCount = maxRetryCount
            
            let bufferTime = try OstBundle
                .getApplicationPlistContent(
                    for: "SESSION_BUFFER_TIME",
                    fromFile: plistFileName
                ) as! Double
            sessionBufferTime = bufferTime
            
        } catch {
            throw OstError("oc_lc_1", .failedToReadOstSdkPlist)
        }
    }

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
}
