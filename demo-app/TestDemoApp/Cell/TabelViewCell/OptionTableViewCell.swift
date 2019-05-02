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
    addSession,
    resetPin,
    viewMnemonics,
    authorizeViaQR,
    authorizeViaMnemonics,
    showDeviceQR,
    manageDevices,
    transactionViaQR,
    initialRecovery,
    abortRecovery
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
    
    let arrowImage: UIImageView = {
        let image = UIImage(named: "Back")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func createViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImage)
        contentView.addSubview(seperatorLine)
        
        self.selectionStyle = .none
    }
    
    override func applyConstraints() {
        applyLabelConstraints()
        applyArrowConstraints()
        applySeperatorLineConstraints()
    }
    
    func applyArrowConstraints() {
        guard let parent = titleLabel.superview else {return}
        arrowImage.rightAnchor.constraint(equalTo: parent.rightAnchor, constant:-18).isActive = true
        arrowImage.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
        arrowImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    func applyLabelConstraints() {
        guard let parent = titleLabel.superview else {return}
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant:15).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant:18).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: arrowImage.rightAnchor, constant:-18).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: seperatorLine.bottomAnchor, constant:-15).isActive = true
    }

    func applySeperatorLineConstraints() {
        guard let parent = titleLabel.superview else {return}
        seperatorLine.bottomAlignWithParent(multiplier: 1, constant: 0)
        seperatorLine.leftAlignWithParent(multiplier: 1, constant: 20)
        seperatorLine.rightAlignWithParent(multiplier: 1, constant: 0)
        seperatorLine.setFixedHeight(toItem: parent, multiplier: 1, constant: 1)
    }
}
