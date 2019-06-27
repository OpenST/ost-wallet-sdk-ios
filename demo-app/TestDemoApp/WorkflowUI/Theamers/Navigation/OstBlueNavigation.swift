//
//  OstCurrentNavigation.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBlueNavigation: OstNavigation {
    
    override init() {
        super.init();
        self.fontProvider = OstFontProvider(fontName: "Lato")
        self.barTintColor = UIColor.color(97, 178, 214)
        self.barTextColor = .white
        self.backBarButtonImage = UIImage(named: "Back")!
    }
}
