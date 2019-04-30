//
//  BaseCollectionViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        createViews()
        initializeVariables()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        initializeVariables()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyConstraints()
    }
    
    //MARK: - Functions to override
    func createViews() {}
    func initializeVariables() {}
    func applyConstraints() {}
    
    func setCellData() {}
    
    func beingDisplay() {}
    
    func endDisplay() {}
}
