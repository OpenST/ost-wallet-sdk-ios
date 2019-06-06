/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class UserDetailsBaseViewModel {
    let title: String
    let value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

class UserDetailsViewModel: UserDetailsBaseViewModel {
    var themer: OstLabelTheamer?
    
    init(title: String, value: String, themer: OstLabelTheamer? = nil) {
        self.themer = themer
        super.init(title: title, value: value)
    }
}

class UserDetailsWithLinkViewModel: UserDetailsViewModel {
    
    var urlString: String? = nil
    
    init(title: String, value: String, themer: OstLabelTheamer? = nil, urlString: String?) {
        self.urlString = urlString
        super.init(title: title, value: value, themer: themer)
    }
}
