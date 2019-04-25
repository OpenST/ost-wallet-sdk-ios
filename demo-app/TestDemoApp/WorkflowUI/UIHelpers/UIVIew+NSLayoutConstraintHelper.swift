//
//  UIVIew+NSLayoutConstraintHelper.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    
    func constrinatHolder(constraintHolder:UIView? = nil, toItem:UIView? = nil) -> UIView? {
        if (nil != constraintHolder) {
            return constraintHolder;
        }
        
        if ( nil != toItem && nil != toItem!.superview && nil != self.superview) {
            //Logic to determine common parent of self and toItem.
            var toParent:UIView? = toItem!.superview;
            var myParent:UIView? = self.superview;
            while( nil != toParent ) {
                while( nil != myParent ) {
                    if ( myParent == toParent ) {
                        return myParent;
                    }
                    myParent = myParent?.superview;
                }
                toParent = toParent?.superview;
            }
        }
        
        //If nothing works:
        return self.superview;
    }
    
    func placeBelow(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 20, addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .bottom,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func centerAlign(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .centerX,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func centerAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            centerAlign(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func leftAlign(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .left,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func leftAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            leftAlign(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func rightAlign(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .right,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .right,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func rightAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            rightAlign(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func bottomAlign(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .bottom,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func bottomAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            bottomAlign(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func applyBlockElementConstraints(horizontalMargin:CGFloat = 20) {
        self.leftAlignWithParent(constant: horizontalMargin);
        self.rightAlignWithParent(constant: (-1.0) * horizontalMargin);
    }
    
}
