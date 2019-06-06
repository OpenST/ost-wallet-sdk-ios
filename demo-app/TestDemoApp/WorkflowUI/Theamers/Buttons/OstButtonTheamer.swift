//
//  CPrimaryButton.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstButtonTheamer:BaseTheamer {
    
    //Title
    public var titleFontSize:CGFloat = 17;
    public var titleColors:[UInt:UIColor] = [:];
    
    //Background
    public var backgroundImages:[UInt:UIImage] = [:];
    public var cornerRadius:CGFloat = 0;
    
    //Content
    public var contentEdgeInsets: UIEdgeInsets?;
    
    //Border
    public var borderWidth:CGFloat = 0;
    public var borderColor:CGColor = UIColor.white.cgColor;
    
    init(titleFontSize:CGFloat) {
        self.titleFontSize = titleFontSize;
    }
    
    func setBackgroundImage(image:UIImage, state:UIButton.State) {
        self.backgroundImages[state.rawValue] = image;
    }
    
    func setTitleColor(color: UIColor, state:UIButton.State) {
        self.titleColors[state.rawValue] = color;
    }
    
    func applyBackgroundImage(button: UIButton, state:UIButton.State) {
        let img = backgroundImages[state.rawValue];
        if ( nil != img ) {
            button.setBackgroundImage(img, for: state);
        }
    }
    
    func applyTitleColor(button: UIButton, state:UIButton.State) {
        let color = titleColors[state.rawValue];
        if ( nil != color ) {
            button.setTitleColor(color, for: state);
        }
    }
    
    
    func apply(_ button:UIButton) {
        
        //Set title font
        // Note for code-reviewer: As per documentation, titleLabel shall not be null.
        // The documentaion states:
        // return title and image views. will always create them if necessary. always returns nil for system buttons
        button.titleLabel!.font = getFontProvider().get(size: titleFontSize);
        
        //Set title colors.
        applyTitleColor(button: button, state: .normal);
        applyTitleColor(button: button, state: .highlighted);
        applyTitleColor(button: button, state: .disabled);
        applyTitleColor(button: button, state: .selected);
        applyTitleColor(button: button, state: .focused);

        //Set title edge insets
        if ( nil != contentEdgeInsets ) {
            button.contentEdgeInsets.top = contentEdgeInsets!.top;
            button.contentEdgeInsets.bottom = contentEdgeInsets!.bottom;
            button.contentEdgeInsets.left = contentEdgeInsets!.left;
            button.contentEdgeInsets.right = contentEdgeInsets!.right;
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
        
        if ( borderWidth > 0 ) {
            button.layer.borderWidth = borderWidth;
            button.layer.borderColor = borderColor;
        }
    }
}
