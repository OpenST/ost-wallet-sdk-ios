//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstLabel: UILabel, UIGestureRecognizerDelegate {
   
    //Label config
    var labelConfig: OstLabelConfig? = nil
    
    //Set label text
    var labelText: String {
        didSet {
            self.text = labelText
        }
    }
    var labelAttributedText: NSAttributedString? = nil
    
    var onLableTapped: (([NSAttributedString.Key: Any]?) -> Void)? = nil
    
    //MARK: - Initialize
    /// Initialize
    ///
    /// - Parameter text: String
    init(text: String = "") {
        self.labelText = text
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    /// Initialize
    ///
    /// - Parameter attributedText: Attributed string for label
    init(attributedText: NSAttributedString) {
        self.labelText = ""
        self.labelAttributedText = attributedText
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    /// Initialize
    ///
    /// - Parameter frame: Frame
    override init(frame: CGRect) {
        self.labelText = ""
        
        super.init(frame: frame)
        applyTheme()
    }
    
    /// Initialize
    ///
    /// - Parameter aDecoder: NSCoder
    required init?(coder aDecoder: NSCoder) {
        self.labelText = ""
        
        super.init(frame: .zero)
        applyTheme()
    }
    
    /// Apply theme for label
    func applyTheme() {
        self.setThemeConfig()
        
        self.numberOfLines = 0
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if nil != labelConfig {
            self.textAlignment = labelConfig!.getAlignment()
            
            self.font = labelConfig!.getFont()
            self.textColor = self.labelConfig!.getColor()
            
            if nil == labelAttributedText {
                self.text = self.labelText
            }else {
                self.attributedText = self.labelAttributedText!
            }
        }
    }
    
    /// Set theme config for button
    func setThemeConfig() {
        
    }
    
    func getText(from data: Any?) -> String {
        if let dict = data as? [String: Any],
            let text = dict["text"] as? String {
            return text
        }
        
        return ""
    }
    
    func getFont(from data: Any?, ofSize size: CGFloat) -> UIFont? {
        if let dict = data as? [String: Any],
            let fontName = dict["font"] as? String {
            return UIFont(name: fontName, size: size)
        }
        return nil
    }
    
    func getForegroundColor(from data: Any?) -> UIColor? {
        if let dict = data as? [String: Any],
            let colorHex = dict["color"] as? String {
            return UIColor.color(hex: colorHex)
        }
        return nil
    }
    
    func updateAttributedText(data: Any?, placeholders: Any?) {
        //Get text from config
        let labelText = getText(from: data)
        //Get font from. config if font is not present, default would be label config font.
        let labelFont = getFont(from: data, ofSize: CGFloat(truncating: labelConfig!.size)) ?? labelConfig!.getFont()
        //get Alignment
        let labelAlignment = labelConfig!.getAlignment()
        //Get foreground color from config. if foreground is not present, default would be label config foreground.
        let labelForegroundColor = getForegroundColor(from: data) ?? labelConfig!.getColor()
        
        //Defaut text attribute
        let attributes: [NSAttributedString.Key : Any] = [.font: labelFont,
                                                          .foregroundColor: labelForegroundColor]
        
        let finalAttributedText: NSMutableAttributedString = NSMutableAttributedString()
        
        let splitWords = labelText.split(separator: " ")
        
        var combinedWords: String = ""
        for word in splitWords {
            //chekc whether word has {{ and }}
            if word.hasPrefix("{{") && word.hasSuffix("}}") {
                //clear {{ and }}
                var newAttributedText: String = String(word.replacingOccurrences(of: "{{", with: ""))
                newAttributedText = String(newAttributedText.replacingOccurrences(of: "}}", with: ""))
                
                //Get data for placeholder text from {{KEY_FOR_TEXT}}
                var placeHoderDict: [String: Any]? = nil
                if let dict = placeholders as? [String: Any] {
                    placeHoderDict = dict[newAttributedText] as? [String: Any]
                }
                
                if nil != placeHoderDict {
                    //Assign attributed text.
                    let attibutedString = NSAttributedString(string: combinedWords,
                                                             attributes: attributes)
                    finalAttributedText.append(attibutedString)
                    
                    combinedWords = ""
                    
                    //Set fonts for placeholder. default is label font
                    var font = labelFont
                    
                    //Set foregroundColor for placeholder. default is label foregroundColor
                    var foregroundColor = labelForegroundColor
                    if let placeHolderFont =  getFont(from: placeHoderDict, ofSize: CGFloat(truncating: self.labelConfig!.size)) {
                        font = placeHolderFont
                    }
                    
                    if let placeHoderForegroundColor = getForegroundColor(from: placeHoderDict) {
                        foregroundColor = placeHoderForegroundColor
                        placeHoderDict!["color"] = nil
                    }
                    //Create new attriutes for placeholder.
                    var newAttributes: [NSAttributedString.Key : Any] = [.font: font,
                                                                         .foregroundColor: foregroundColor]
                    //Set extra keys in attributes
                    for (key, val) in placeHoderDict! {
                        newAttributes[.init(key)] = val
                    }
                    let text = getText(from: placeHoderDict!)
                    let newAttributedString = NSAttributedString(string: "\(text) ", attributes: newAttributes)
                    
                    finalAttributedText.append(newAttributedString)
                }
            }else {
                combinedWords += "\(word) "
            }
        }
        
        if combinedWords.count > 0 {
            let attibutedString = NSAttributedString(string: combinedWords,
                                                     attributes: attributes)
            finalAttributedText.append(attibutedString)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = labelAlignment
        finalAttributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, finalAttributedText.length))
        
        self.attributedText = finalAttributedText
        
        addTapGesture()
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_ :)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
    
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped(_ recognizer: UITapGestureRecognizer) {
        
        let label = recognizer.view as! UILabel
        let textView: UITextView = UITextView(frame: label.frame)
        textView.attributedText = label.attributedText
        
        let layoutManager: NSLayoutManager = textView.layoutManager
        var location = recognizer.location(in: label)
        location.x -= textView.textContainerInset.left;
        //        location.y -= textView.textContainerInset.top;
        
        let characterIndex: Int = layoutManager.characterIndex(for: location,
                                                               in: textView.textContainer,
                                                               fractionOfDistanceBetweenInsertionPoints: nil)
        
        if (characterIndex < textView.textStorage.length) {
            let attributes = textView.textStorage.attributes(at: characterIndex, effectiveRange: nil)
            onLableTapped?(attributes)
        }
    }
    
}

