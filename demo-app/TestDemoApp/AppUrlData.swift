/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation;
import OstWalletSdk;

class AppUrlData {
    let url:URL;
    let action:Actions;
    let actionString:String;
    let params:[String:Any];
    enum Actions: String, CaseIterable {
        case launch,
        transactions,
        unknown;
        

        //
        static func getAction(forString str: String) -> Actions {
            for currAction in Actions.allCases {
                if ( currAction.rawValue.caseInsensitiveCompare( str ) == .orderedSame ) {
                    return currAction;
                }
            }
            return .unknown
        }
    }
    
    init(url:URL) {
        self.url = url;
        let pathComponents = url.pathComponents;
        self.actionString =  (pathComponents[2] as String).lowercased();
        self.action = Actions.getAction(forString: self.actionString);
        self.params = OstUtils.getQueryParams(url: url);
    }
}
