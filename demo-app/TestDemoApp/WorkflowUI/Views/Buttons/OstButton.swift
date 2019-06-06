//
//  OstButton.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var theamer:OstButtonTheamer?
    public func setTheamer(_ theamer:OstButtonTheamer? ) {
        self.theamer = theamer;
    }


    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
                self.alpha = 1.0;
            } else {
                self.alpha = 0.30;
            }
        }
    }
}
