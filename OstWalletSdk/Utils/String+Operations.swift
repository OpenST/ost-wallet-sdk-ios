/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension String {
    
    public func isMatch(_ regex: String) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        let regex = try! NSRegularExpression(pattern: regex)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    public  func substringAfter(_ offset: Int) -> String {
        let startIndex = index(self.startIndex, offsetBy: offset)
        if (startIndex < endIndex) {
            let substingVal = self[startIndex..<endIndex]
            return String(substingVal)
        }
        return ""
    }
    
    public  func padLeft (totalWidth: Int, with: String) -> String {
        let toPad = totalWidth - self.count
        if toPad < 1 { return self }
        return "".padding(toLength: toPad, withPad: with, startingAt: 0) + self
    }

    public  func rightPad (totalWidth: Int, with: String) -> String {
        if totalWidth < 1 { return self }
        return padding(toLength: totalWidth, withPad: with, startingAt: 0)
    }

    public var hexString: String {
        let data = Data(self.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
    }
    
    public var isAddress: Bool {
        return self.isMatch("^(0x|0X)?[0-9a-fA-F]{40}$")
    }
    
    public func groups(for regexPattern: String) -> [[String]] {
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
        } catch {
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
    
    func indexOf(_ input: String,
                   options: String.CompareOptions = .literal) -> String.Index? {
        return self.range(of: input, options: options)?.lowerBound
    }
        
    func lastIndexOf(_ input: String) -> Int {
        guard let lastIndex = indexOf(input, options: .backwards) else {
            return -1
        }
        return self.distance(from: self.startIndex, to: lastIndex)
    }
    
    var encodedString: String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "`@#$%^&+={}[]:;/\"<>,?|\\ '!()*").inverted)
        if let escapedString = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString.replaceCharacter("%20", with: "+")
        }
        return self.replaceCharacter("%20", with: "+")
    }
    
    func replaceCharacter(_ pattern: String, with replaceString:String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, self.count)
        let modifiedString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceString)
        return modifiedString
    }
    
    var decodedString: String {
        if let unescapedString = self.removingPercentEncoding {
            return unescapedString
        }
        return self
    }
    
    public var isValidAddress: Bool {
        let addressRegex = "^(0x)[0-9a-fA-F]{40}$"
        return self.isMatch(addressRegex)
    }
    
    public  func toDisplayTxValue(decimals: Int) -> String {
        var formattedDecimal: String = ""
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // USA: Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        let number = formatter.number(from: self) ?? 0
        let convertedVal = "\(number.decimalValue)"
        
        let values = convertedVal.components(separatedBy: ".")
        if values.count == 2 {
            let decimalVal: String = values[1]
            
            let trimDecimals = decimalVal.substringTill(decimals+1)
            if !trimDecimals.isEmpty {
                let floatVal: CGFloat = CGFloat(Double("0.\(trimDecimals)") ?? Double(0))
                formattedDecimal = String(format: "%.\(decimals)f", floatVal)
                formattedDecimal = formattedDecimal.components(separatedBy: ".")[1]
            }
        }
        
        var decimalPart = ""
        if (OstUtils.toDouble(formattedDecimal) ?? 0) > 0 {
            formattedDecimal = OstUtils.trimTrailingZeros(formattedDecimal)
            decimalPart = ".\(formattedDecimal)"
        }
        let intDouble = (Double(values[0]) ?? 0).avoidNotation
        let fialRoundUpVal = "\(intDouble)\(decimalPart)"
        
        return String(OstUtils.trimTrailing(Substring(fialRoundUpVal), suffix: "."))
    }
    
    public func substringTill(_ offset: Int) -> String {
        if self.count < offset {
            return self
        }
        let endIndex = index(self.startIndex, offsetBy: offset)
        let substingVal = self[self.startIndex..<endIndex]
        return String(substingVal)
    }
}
