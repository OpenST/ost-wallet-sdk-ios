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
        DispatchQueue.main.async {
            let componentSheet = OstComponentSheet.getInstance()
            componentSheet.presentVCWithNavigation()
        }
    }
    
    class func getInstance() -> OstComponentSheet {
        let componentSheet = OstComponentSheet()
        return componentSheet
    }
    
    //MARK:- Labels
    let h1 = OstH1Label(text: "H1: Quick Brown Fox Jumps Over The Lazy Dog")
    let h2 = OstH2Label(text: "H2: Quick Brown Fox Jumps Over The Lazy Dog")
    let h3 = OstH3Label(text: "H3: Quick Brown Fox Jumps Over The Lazy Dog")
    let h4 = OstH4Label(text: "H4: Quick Brown Fox Jumps Over The Lazy Dog")
    
    let c1 = OstC1Label(text: "C1: Quick Brown Fox Jumps Over The Lazy Dog")
    let c2 = OstC2Label(text: "C2: Quick Brown Fox Jumps Over The Lazy Dog")
    
    //MARK:- Buttons
    let b1 = OstB1Button(title: "B1: Quick Brown Fox Jumps Over The Lazy Dog")
    let b2 = OstB2Button(title: "B2: Quick Brown Fox Jumps Over The Lazy Dog")
    let b3 = OstB3Button(title: "B3: Quick Brown Fox Jumps Over The Lazy Dog")
    
    //MARK:- Pin Input
    let pinInput: OstPinInput = OstPinInput()
    
    
    override func configure() {
        super.configure()
        
        pinInput.isUserInteractionEnabled = false
        pinInput.updateDots(currentPinLength: 3)
    }
    
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
        self.addSubview(pinInput)
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
        
        pinInput.placeBelow(toItem: b3)
        pinInput.centerXAlignWithParent()
        
        let lastView = pinInput
        lastView.bottomAlignWithParent()
    }
}
