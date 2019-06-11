/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension Date {
    
    func getFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        
        return dateFormatter
    }
    
    func getDateWithTimeString() -> String {
        let formatter = getFormatter()
        formatter.dateFormat = "dd/MM/yyy HH:mm:ss" //Specify your format that you want
        let strDate = formatter.string(from: self)
        return strDate
    }
    
    func getDateString() -> String {
        let formatter = getFormatter()
        formatter.dateFormat = "dd/MM/yyy" //Specify your format that you want
        let strDate = formatter.string(from: self)
        return strDate
    }
}
