//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class OstBaseButton: UIButton {
    //Title
    public var titleFontSize:CGFloat = 17;
    public var titleColors:[UInt:UIColor] = [:];
    
    //Background
    public var backgroundImages:[UInt:UIImage] = [:];
    public var cornerRadius:CGFloat = 0;
    
    //Content
    public var cEdgeInsets: UIEdgeInsets?;
    
    //Border
    public var borderWidth:CGFloat = 0;
    public var borderColor:CGColor = UIColor.white.cgColor;
    
    public var buttonConfig: OstButtonConfig? = nil
    
    public let buttonTitleText: String
    
    
    /// Initialize
    ///
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        self.buttonTitleText = ""
        
        super.init(frame: .zero)
    }
    
    /// Initialize
    ///
    /// - Parameter title: String
    init(title: String) {
        self.buttonTitleText = title
        super.init(frame: .zero)
        
        self.apply(self)
    }
    
    /// Initialize
    ///
    /// - Parameter aDecoder: NSCoder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set background image for button state
    ///
    /// - Parameters:
    ///   - image: Image to set
    ///   - state: Button state
    func setBackgroundImage(image:UIImage, state:UIButton.State) {
        self.backgroundImages[state.rawValue] = image;
    }
    
    /// Set title color for button
    ///
    /// - Parameters:
    ///   - color: Color to set
    ///   - state: Button state
    func setTitleColor(color: UIColor, state:UIButton.State) {
        self.titleColors[state.rawValue] = color;
    }
    
    /// Set background image for button
    ///
    /// - Parameters:
    ///   - button: Button object
    ///   - state: Button state
    func applyBackgroundImage(button: UIButton, state:UIButton.State) {
        let img = backgroundImages[state.rawValue];
        if ( nil != img ) {
            button.setBackgroundImage(img, for: state);
        }
    }
    
    /// Apply title color to button title
    ///
    /// - Parameters:
    ///   - button: Button object
    ///   - state: Button state
    func applyTitleColor(button: UIButton, state:UIButton.State) {
        let color = titleColors[state.rawValue];
        if ( nil != color ) {
            button.setTitleColor(color, for: state);
        }
    }
    
    /// Apply config to button
    ///
    /// - Parameter button: Button
    func apply(_ button:UIButton) {
        
        setThemeConfig()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(buttonTitleText, for: .normal)
        
        button.titleLabel!.font = self.buttonConfig!.getFont()
        
        //Set title colors.
        applyTitleColor(button: button, state: .normal);
        applyTitleColor(button: button, state: .highlighted);
        applyTitleColor(button: button, state: .disabled);
        applyTitleColor(button: button, state: .selected);
        applyTitleColor(button: button, state: .focused);
        
        //Set title edge insets
        if ( nil != cEdgeInsets ) {
            button.contentEdgeInsets.top = cEdgeInsets!.top;
            button.contentEdgeInsets.bottom = cEdgeInsets!.bottom;
            button.contentEdgeInsets.left = cEdgeInsets!.left;
            button.contentEdgeInsets.right = cEdgeInsets!.right;
        }
        
        //Set background Image
        applyBackgroundImage(button: button, state: .normal);
        applyBackgroundImage(button: button, state: .highlighted);
        applyBackgroundImage(button: button, state: .disabled);
        applyBackgroundImage(button: button, state: .selected);
        applyBackgroundImage(button: button, state: .focused);
        
        //Set corner-radius
        if ( cornerRadius > 0 ) {
            button.layer.cornerRadius = cornerRadius;
            button.clipsToBounds = true;
        }
        
        //Set border with
        if ( borderWidth > 0 ) {
            button.layer.borderWidth = borderWidth;
            button.layer.borderColor = borderColor;
        }
    }
    
    /// Set theme config for button
    func setThemeConfig() {
        fatalError("setThemeConfig did not override")
    }
}
