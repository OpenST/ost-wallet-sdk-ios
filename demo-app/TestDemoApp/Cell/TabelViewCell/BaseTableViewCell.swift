//
//  BaseTableViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
//    let containerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
        applyConstraints()

        setVariables()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setVariables()
        createViews()
        applyConstraints()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        applyConstraints()
    }
    
    //MARK: - Functions to override
    func createViews() {
//        self.addSubview(containerView)
    }
    func setVariables() {}
    func applyConstraints() {
//        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func beingDisplay() {}
    
    func endDisplay() {}
    
}

