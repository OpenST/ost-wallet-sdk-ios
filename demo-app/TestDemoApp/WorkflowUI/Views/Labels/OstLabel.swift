//
//  OstLabel.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var theamer:OstLabelTheamer?
    public func setTheamer(_ theamer:OstLabelTheamer? ) {
        self.theamer = theamer;
    }
    
    override var text: String? {
        didSet {
            self.theamer?.setText(self, text: text);
        }
    }
    
    public func setText(_ text:String?) {
        if ( nil == theamer ) {
            self.text = text;
            return;
        }
        theamer?.setText(self, text: text);
    }

}
