//
//  UIImage+Helper.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func withColor(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Float = 1.0) -> UIImage {
        let color = UIColor.color(red, green, blue, alpha);
        return UIImage.withColor(color: color);
    }
    
    class func withColor(color:UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
