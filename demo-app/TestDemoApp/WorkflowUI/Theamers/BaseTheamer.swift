//
//  BaseTheamer.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class BaseTheamer {

    //Font-Provider
    public var fontProvider:OstFontProvider?;
    
    public init(){
        print("BaseTheamer:init()");
    }
    
    public func getFontProvider() -> OstFontProvider {
        if ( nil != fontProvider) {
            return fontProvider!;
        }
        return OstTheme.fontProvider;
    }
    
    public func apply(_ view: UIView) {
        preconditionFailure("Must be overridden by derived class");
    }
    
}
