//
//  BaseTableViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseTableViewCell: UITableViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setVariables()
        
        createViews()
        applyConstraints()
        setValuesForComponents()
        
        self.selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setVariables()
        
        createViews()
        applyConstraints()
        
        setValuesForComponents()
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// Add view to table view cells content view
    ///
    /// - Parameter view: View
    func addToContentView(_ view: UIView) {
        self.contentView.addSubview(view)
    }

    //MARK: - Functions to override
    
    /// Set variables
    func setVariables() {}
    
    /// Craete views
    func createViews() {}

    /// Apply constrains
    func applyConstraints() {}
    
    /// Set values for components
    func setValuesForComponents() {}
    
    func beingDisplay() {}
    
    func endDisplay() {}
    
}

