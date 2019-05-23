//
//  OptionTableViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

enum OptionType {
    case details,
    createSession,
    resetPin,
    viewMnemonics,
    biomerticStatus,
    authorizeViaQR,
    authorizeViaMnemonics,
    showDeviceQR,
    manageDevices,
    transactionViaQR,
    initiateDeviceRecovery,
    abortRecovery,
    logoutAllSessions
}

struct OptionVM {
    var type: OptionType
    var name: String = ""
    var isEnable: Bool = true
}

class OptionTableViewCell: BaseTableViewCell {
    
    var option: OptionVM! {
        didSet {
            titleLabel.text = option.name
            if option.isEnable {
                titleLabel.alpha = 1.0
            }else {
                titleLabel.alpha = 0.3
            }
        }
    }
    
    static var cellIdentifier: String {
        return "OptionTableViewCell"
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Lato", size: 14)
        label.textColor = UIColor.color(52, 68, 91)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func createViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(seperatorLine)
        
        self.selectionStyle = .none
    }
    
    override func applyConstraints() {
        applyLabelConstraints()
        applySeperatorLineConstraints()
    }
    
    func applyLabelConstraints() {
        guard let parent = titleLabel.superview else {return}
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant:15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant:30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant:-18).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: seperatorLine.bottomAnchor, constant:-15).isActive = true
    }

    func applySeperatorLineConstraints() {
        seperatorLine.bottomAlignWithParent(constant: 0)
        seperatorLine.leftAlignWithParent(constant: 30)
        seperatorLine.rightAlignWithParent(constant: 0)
        seperatorLine.setFixedHeight(constant: 0.5)
    }
}
