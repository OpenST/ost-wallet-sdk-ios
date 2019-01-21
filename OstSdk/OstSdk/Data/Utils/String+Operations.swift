//
//  String+Operations.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension String {
    var isUUID: Bool {
        return !isEmpty && range(of: "[^-a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    func isMatch(_ regex: String) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        let regex = try! NSRegularExpression(pattern: regex)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    func substring(_ offset: Int) -> String {
        let startIndex = index(self.startIndex, offsetBy: offset)
        if (startIndex < endIndex) {
            let substingVal = self[startIndex..<endIndex]
            return String(substingVal)
        }
        return ""
    }
    
    func padLeft (totalWidth: Int, with: String) -> String {
        let toPad = totalWidth - self.count
        if toPad < 1 { return self }
        return "".padding(toLength: toPad, withPad: with, startingAt: 0) + self
    }

    func rightPad (totalWidth: Int, with: String) -> String {
        if totalWidth < 1 { return self }
        return padding(toLength: totalWidth, withPad: with, startingAt: 0)
    }

    var hexString: String {
        let data = Data(self.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
    }
    
    var isAddress: Bool {
        return self.isMatch("^(0x|0X)?[0-9a-fA-F]{40}$")
    }
    
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    public func stripHexPrefix() -> String {
        var hex = self
        let prefix = "0x"
        if hex.hasPrefix(prefix) {
            hex = String(hex.dropFirst(prefix.count))
        }
        return hex
    }
    
    public func addHexPrefix() -> String {
        let prefix = "0x"
        if self.hasPrefix(prefix){
            return self
        }
        return prefix.appending(self)
    }
    
    public func toHexString() -> String {
        return data(using: .utf8)!.map { String(format: "%02x", $0) }.joined()
    }
    
    public func toDictionary() throws -> [String: Any?] {
        let data = self.data(using: .utf8)!
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any?]
    }
}
