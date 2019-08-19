/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class OstTextView: OstBaseView, UITextViewDelegate {

    let textViewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.color(151, 151, 151, 0.5).cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocapitalizationType = .none
        view.backgroundColor = .clear
    
        return view
    }()
    
    let placeholderLabel: OstLabel  = {
        let view = OstLabel()
        
        return view
    }()
 
    let errorLabel: OstLabel = {
        let label = OstLabel()
        label.textAlignment = .left
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    weak var delegate: UITextViewDelegate? = nil
    
    //MARK: - Setter
    var errorText: String? {
        didSet {
            errorLabel.text = errorText
        }
    }
    
    func setErrorText(_ text: String?) {
        errorText = text
    }
    
    func setPlaceholderText(_ text: String) {
        self.placeholderLabel.text = text
    }
 
    //MARK: - Getter
    var text: String {
        return textView.text
    }
    
    override func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        weak var weakSelf = self
        textView.delegate = weakSelf
        
        configureTheme()
    }
    
    func configureTheme() {
        let textViewTheme = OstTheme.getInstance().getTextViewConfig()
        
        textView.textColor = textViewTheme.getColor()
        textView.font = textViewTheme.getFont()
        
        let placeholderConfig = OstLabelConfig(config: textViewTheme.config["placeholder"] as! [String: Any])
        placeholderLabel.font = placeholderConfig.getFont()
        placeholderLabel.textColor = placeholderConfig.getColor()
        
        textViewContainer.backgroundColor = textViewTheme.getBackgroundColor()
    }
    
    override func createViews() {
        self.addSubview(textViewContainer)
        textViewContainer.addSubview(placeholderLabel)
        textViewContainer.addSubview(textView)
        self.addSubview(errorLabel)
    }
    
    override func applyConstraints() {
        applyTextViewContainerConstraints()
        applyTextViewConstraints()
        applyPlaceholderLabelConstraints()
        applyErrorLabelConstraints()
    }
    
    func applyTextViewContainerConstraints() {
        textViewContainer.topAlignWithParent(multiplier: 1, constant: 5)
        textViewContainer.applyBlockElementConstraints(horizontalMargin: 0)
        textViewContainer.bottomAlign(toItem: textView, constant: -8)
    }
    
    func applyTextViewConstraints() {
        textView.topAlignWithParent(multiplier: 1, constant: 5)
        textView.applyBlockElementConstraints(horizontalMargin: 8)
        textView.setH667Height(height: 133)
    }
    
    func applyPlaceholderLabelConstraints() {
        placeholderLabel.topAlign(toItem: textView, constant:8)
        placeholderLabel.leftAlign(toItem: textView,  constant:4)
        placeholderLabel.rightAlign(toItem: textView, multiplier: 1, constant: -10, relatedBy: .lessThanOrEqual)
        placeholderLabel.bottomAlign(toItem: textView, multiplier: 1, constant: 0, relatedBy: .lessThanOrEqual)
    }
    
    func applyErrorLabelConstraints() {
        errorLabel.placeBelow(toItem: textViewContainer, constant:4)
        errorLabel.leftAlign(toItem: textViewContainer, constant:4)
        errorLabel.rightAlign(toItem: textViewContainer)
        errorLabel.bottomAlignWithParent(constant: 0)
    }
    
    //MARK: - TextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        if delegate?.responds(to: #selector(textViewDidChange(_:))) ?? false {
            delegate?.textViewDidChange?(textView)
        }
        
        self.placeholderLabel.isHidden = textView.text.count > 0
    }
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        return self.endEditing(force)
    }
}
