/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstPinVCConfig: NSObject {
    
    let titleLabelData: Any?
    let leadLabelData: Any?
    let infoLabelData: Any?
    let tcLabelData: Any?
    let placeholders: Any?
    
    init(titleLabelData: Any?,
         leadLabelData: Any?,
         infoLabelData: Any?,
         tcLabelData: Any?,
         placeholders: Any?) {
        
        self.titleLabelData = titleLabelData
        self.leadLabelData = leadLabelData
        self.infoLabelData = infoLabelData
        self.tcLabelData = tcLabelData
        self.placeholders = placeholders
        
        super.init()
    }
}
