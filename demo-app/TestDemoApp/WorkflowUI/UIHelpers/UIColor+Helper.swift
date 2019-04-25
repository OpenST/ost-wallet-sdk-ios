//
//  UIColor+Helper.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public class func color(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Float = 1.0) -> UIColor {
        let f255 = CGFloat(255);
        let r = CGFloat( red ) / f255;
        let g = CGFloat( green ) / f255;
        let b = CGFloat( blue ) / f255;
        let a = CGFloat( alpha );
        return UIColor(red: r, green: g, blue: b, alpha: a);
    }
}
