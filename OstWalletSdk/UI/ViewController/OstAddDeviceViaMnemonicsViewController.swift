/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddDeviceViaMnemonicsViewController: OstBaseScrollViewController, UITextViewDelegate {
    
    class func newInstance(onActionTapped: ((String) -> Void)?) -> OstAddDeviceViaMnemonicsViewController {
        
        let instance = OstAddDeviceViaMnemonicsViewController()
        instance.onActionTapped = onActionTapped
        return instance
    }
    
    var onActionTapped: ((String) -> Void)? = nil
    
    
    //MARK: - Components
    let titleLabel: OstH1Label = OstH1Label()
    let infoLabel: OstH3Label = OstH3Label()
    let tcLabel: OstH4Label = OstH4Label()
    let actionButton: OstB1Button = OstB1Button()
    let textView: OstTextView = OstTextView()

    override func configure() {
        super.configure()

        let viewConfig = OstContent.getAddDeviceViaMnemonicsVCConfig()

        titleLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.titleLabel.getComponentName()],
                                        placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])

        infoLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.infoLabel.getComponentName()],
                                       placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])

        tcLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.bottomLabel.getComponentName()],
                                     placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])

        setActionButtonText(pageConfig: viewConfig)
        
        textView.setPlaceholderText(getPlaceholderText(pageConfig: viewConfig))

        weak var weakSelf = self
        textView.delegate = weakSelf
        actionButton.addTarget(weakSelf, action: #selector(weakSelf!.recoverWalletButtonTapped(_:)), for: .touchUpInside)

        self.shouldFireIsMovingFromParent = true;
    }
    
    func getPlaceholderText(pageConfig: [String: Any]) -> String {
        if let placeholder = pageConfig["placeholder"] as? [String: Any],
            let text = placeholder["text"] as? String {
            return text
        }
        
        return ""
    }

    func setActionButtonText(pageConfig: [String: Any]) {
        var buttonTitle = ""
        if let actionButton = pageConfig["action_button"] as? [String: Any],
            let text = actionButton["text"] as? String {

            buttonTitle = text
        }

        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _ = textView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = textView.becomeFirstResponder()
    }

    //MAKR: - Add Subviews
    override func addSubviews() {
        super.addSubviews()

        self.addSubview(titleLabel)
        self.addSubview(infoLabel)
        self.addSubview(tcLabel)
        self.addSubview(actionButton)
        self.addSubview(textView)
    }

    //MAKR: - Apply Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()

        addTitleLableConstraints()
        addInfoLabelConstraints()
        applyTextViewConstraints()
        addActionButtonConstraints()
        addTCLabelConstraints()

        let last = tcLabel
        last.bottomAlignWithParent()
    }

    func addTitleLableConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20)
        titleLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }

    func addInfoLabelConstraints() {
        infoLabel.placeBelow(toItem: titleLabel)
        infoLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }

    func applyTextViewConstraints() {
        textView.placeBelow(toItem: infoLabel)
        textView.applyBlockElementConstraints(horizontalMargin: 25)
    }

    func addActionButtonConstraints() {
        actionButton.placeBelow(toItem: textView, constant: 30)
        actionButton.applyBlockElementConstraints(horizontalMargin: 25)
    }

    func addTCLabelConstraints() {
        tcLabel.placeBelow(toItem: actionButton)
        tcLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }

    //MARK: - TextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if "\n".caseInsensitiveCompare(text) == .orderedSame {
            _ = self.textView.resignFirstResponder()
            return false
        }
        return true
    }

    func isValidInput() -> Bool {
        var mnemonics: [String] = self.textView.text.components(separatedBy: " ")
        mnemonics = mnemonics.filter({
            let text = $0.replacingOccurrences(of: " ", with: "")
            return !text.isEmpty
        })

        if mnemonics.count == 12 {
            textView.setErrorText(nil);
            self.view.layoutIfNeeded()
            return true
        }

        textView.setErrorText("Invalid Mnemonics passed.");
        self.view.layoutIfNeeded()
        return false
    }

    //MARK: - Action
    @objc func recoverWalletButtonTapped(_ sender: Any?) {
        if isValidInput() {
           onActionTapped?(self.textView.text)
        }
    }
}
