//
//  UIFont+Helpers.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits, size: CGFloat) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: size) //size 0 means keep the size as it is
    }
    
    func bold(size: CGFloat = 0) -> UIFont {
        return withTraits(traits: .traitBold, size: size);
    }
    
    func italic(size: CGFloat = 0) -> UIFont {
        return withTraits(traits: .traitItalic, size: size);
    }
}
