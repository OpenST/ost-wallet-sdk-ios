//
//  MnemonicsCollectionViewCell.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class MnemonicsCollectionViewCell: BaseCollectionViewCell {
    
    var mnemonics: String?
    var mnemonicsLabel: UILabel?
    
    static var cellIdentifier: String {
        return "MnemonicsCollectionViewCell"
    }
    
    override func createViews() {
        super.createViews()
        createLabel()
    }
    
    func createLabel() {
        let label = UILabel()
        label.font = OstFontProvider(fontName: "Lato").get(size: 16)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        mnemonicsLabel = label
        self.addSubview(label)
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        applyMnemonicsConstraints()
    }
    
    func applyMnemonicsConstraints() {
        guard let parent = mnemonicsLabel?.superview else {return}
        
        mnemonicsLabel?.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        mnemonicsLabel?.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        mnemonicsLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        mnemonicsLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
    }
    
    func setCellData(mnemonics: String, index: Int) {
        self.mnemonicsLabel?.text = "\(index). \(mnemonics)"
    }

    
}
