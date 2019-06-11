/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class UserDetailsTableViewCell: BaseTableViewCell {
    
    static var userDetailsCellIdentifier: String {
        return String(describing: UserDetailsTableViewCell.self)
    }
    
    //MARK: - Components
    var titleLabel: UILabel = {
        let view =  UILabel()
        view.font = OstTheme.fontProvider.get(size: 13).bold()
        view.textAlignment = .left
        view.textColor = UIColor.black.withAlphaComponent(0.4)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var infoText: UILabel = {
        let view =  UILabel()
        view.font = OstTheme.fontProvider.get(size: 15)
        view.textAlignment = .left
        view.textColor = UIColor.color(52, 68, 91)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var seperatorLine: UIView = {
        var seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.color(244, 244, 244)
        
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        return seperatorLine
    }()
    
    //MAKR: - Add SubView
    override func createViews() {
        super.createViews()
        addSubview(titleLabel)
        addSubview(infoText)
        addSubview(seperatorLine)
        self.selectionStyle = .none
    }

    //MARK: - Add Constraints
    override func applyConstraints() {
        super.applyConstraints()
        addTitleLabelConstraints()
        addInfoLabelConstraints()
        addSeperatorLineConstraints()
    }
    
    func addTitleLabelConstraints() {
        guard let parent = titleLabel.superview else {return}
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 14).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 14).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -14).isActive = true
    }
    
    func addInfoLabelConstraints() {
        infoText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        infoText.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        infoText.bottomAnchor.constraint(equalTo: seperatorLine.topAnchor, constant: -14).isActive = true
        
        infoLabelRightAnchor()
    }
    
    func infoLabelRightAnchor() {
        guard let parent = infoText.superview else {return}
        infoText.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -14).isActive = true
    }
    
    func addSeperatorLineConstraints() {
        guard let parent = seperatorLine.superview else {return}
        seperatorLine.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        seperatorLine.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        seperatorLine.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    //MARK: - Variables
    var userDetails: UserDetailsViewModel! {
        didSet {
            setupUserDetails(details: userDetails)
        }
    }
    
    func setupUserDetails(details: UserDetailsViewModel) {
        self.titleLabel.text = details.title
        self.infoText.text = details.value
        if nil != details.themer {
            details.themer?.apply(self.infoText)
        }
    }
}
