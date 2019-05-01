//
//  AuthorizeDeviceViaMnemonicsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents


class AuthorizeDeviceViaMnemonicsViewController: BaseSettingOptionsViewController {
    
    let wordsTextView: MDCMultilineTextField = {
        let wordsTextView = MDCMultilineTextField()
        wordsTextView.translatesAutoresizingMaskIntoConstraints = false
        wordsTextView.isEnabled = true;
        wordsTextView.text = "toilet lock dice twist surge feel awesome rapid amateur tortoise first afraid"
        wordsTextView.minimumLines = 3;
        return wordsTextView
    }()
    var wordsTextController:MDCTextInputControllerOutlinedTextArea? = nil;
    
    
    override func getNavBarTitle() -> String {
        return "Enter 12-word Mnemonic"
    }
    
    override func getLeadLabelText() -> String {
        return "Please enter the 12-word mnemonic phrase that you wrote down. If you don’t have the mnemonic phrase, try using PIN or a second authorized device."
    }
    
    override func addSubviews() {
        super.addSubviews()
        self.wordsTextController = MDCTextInputControllerOutlinedTextArea(textInput: wordsTextView);
        self.wordsTextController?.placeholderText = "Enter mnemonic Phrase…"
        
        addSubview(wordsTextView)
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addTextFiledLayoutConstraints()
    }
    
    func addTextFiledLayoutConstraints() {
        wordsTextView.placeBelow(toItem: leadLabel, constant: 22)
        wordsTextView.centerXAlignWithParent()
        wordsTextView.setAspectRatio(width: 325, height: 133);
    }
}
