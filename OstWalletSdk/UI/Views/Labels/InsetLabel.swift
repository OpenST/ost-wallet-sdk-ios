/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class InsetLabel: UILabel {
    
    var padding: CGFloat! {
        didSet {
            paddingWidth = padding
            paddingHeight = padding
        }
    }
    var paddingWidth: CGFloat = 0.0
    var paddingHeight: CGFloat = 0.0
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: UIEdgeInsets(top: paddingHeight,
                                                    left: paddingWidth,
                                                    bottom: paddingHeight,
                                                    right: paddingWidth))
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }
    
    private func addInsets(to size: CGSize) -> CGSize {
        let contentInsets = UIEdgeInsets(top: paddingHeight,
                                         left: paddingWidth,
                                         bottom: paddingHeight,
                                         right: paddingWidth)
        
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }
    
}
