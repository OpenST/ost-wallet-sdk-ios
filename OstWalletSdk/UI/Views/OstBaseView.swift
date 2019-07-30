//
//  OstBaseView.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 02/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseView: UIView {
    deinit {
        print("deinit: \(String(describing: self))")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
        applyConstraints()
        
    }
    
    func createViews() {}
    func applyConstraints() {}
    
}
