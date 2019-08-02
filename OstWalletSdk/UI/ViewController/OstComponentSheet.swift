/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstComponentSheet: OstBaseScrollViewController {
    
    class func showComponentSheet() {
        let componentSheet = getInstance()
        componentSheet.presentVCWithNavigation()
    }
    
    class func getInstance() -> OstComponentSheet {
        let componentSheet = OstComponentSheet()
        return componentSheet
    }
    
    //Labels
    let h1 = OstH1Label(text: "This is h1 label")
    let h2 = OstH2Label(text: "This is h2 label")
    let h3 = OstH3Label(text: "This is h3 label")
    let h4 = OstH4Label(text: "This is h4 label")
    
    let c1 = OstC1Label(text: "This is c1 label")
    let c2 = OstC2Label(text: "This is c2 label")
    
    let b1 = OstB1Button(title: "This is b1 button")
    let b2 = OstB2Button(title: "This is b2 button")
    let b3 = OstB3Button(title: "This is b3 button")
    let b4 = OstB1Button(title: "This is b4 button (Not Present Yet)")
    
    override func addSubviews() {
        super.addSubviews()
        
        self.addSubview(h1)
        self.addSubview(h2)
        self.addSubview(h3)
        self.addSubview(h4)
        self.addSubview(c1)
        self.addSubview(c2)
        self.addSubview(b1)
        self.addSubview(b2)
        self.addSubview(b3)
        self.addSubview(b4)
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        h1.topAlignWithParent(multiplier: 1, constant: 20)
        h1.applyBlockElementConstraints()
        
        h2.placeBelow(toItem: h1)
        h2.applyBlockElementConstraints()
        
        h3.placeBelow(toItem: h2)
        h3.applyBlockElementConstraints()
        
        h4.placeBelow(toItem: h3)
        h4.applyBlockElementConstraints()
        
        c1.placeBelow(toItem: h4)
        c1.applyBlockElementConstraints()
        
        c2.placeBelow(toItem: c1)
        c2.applyBlockElementConstraints()
        
        b1.placeBelow(toItem: c2)
        b1.applyBlockElementConstraints()
        
        b2.placeBelow(toItem: b1)
        b2.applyBlockElementConstraints()
        
        b3.placeBelow(toItem: b2)
        b3.centerXAlignWithParent()
        
        b4.placeBelow(toItem: b3)
        b4.centerXAlignWithParent()
        
        let lastView = b4
        lastView.bottomAlignWithParent()
    }
}
