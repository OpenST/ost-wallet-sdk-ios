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
        
        if ( nil != toItem ) {
            //Logic to determine common parent of self and toItem.
            var toParent:UIView? = toItem;
            while( nil != toParent ) {
                var myParent:UIView? = self;
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
        return UIApplication.shared.keyWindow;
    }
    
    func placeBelow(toItem:UIView,
                    multiplier:CGFloat = 1, constant:CGFloat = 20,
                    relatedBy: NSLayoutConstraint.Relation = .equal,
                    addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .top,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .bottom,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func centerAlignX(toItem:UIView,
                      multiplier:CGFloat = 1, constant:CGFloat = 0,
                      relatedBy: NSLayoutConstraint.Relation = .equal,
                      addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .centerX,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .centerX,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func centerXAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            centerAlignX(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func centerAlignY(toItem:UIView,
                      multiplier:CGFloat = 1, constant:CGFloat = 0,
                      relatedBy: NSLayoutConstraint.Relation = .equal,
                      addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .centerY,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .centerY,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func centerYAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            centerAlignY(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func leftAlign(toItem:UIView,
                   multiplier:CGFloat = 1, constant:CGFloat = 0,
                   relatedBy: NSLayoutConstraint.Relation = .equal,
                   addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .left,
                                              relatedBy: relatedBy,
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
    
    func leftWithRightAlign(toItem:UIView,
                            multiplier:CGFloat = 1, constant:CGFloat = 0,
                            relatedBy: NSLayoutConstraint.Relation = .equal,
                            addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .left,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .right,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func rightAlign(toItem:UIView,
                    multiplier:CGFloat = 1, constant:CGFloat = 0,
                    relatedBy: NSLayoutConstraint.Relation = .equal,
                    addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .right,
                                              relatedBy: relatedBy,
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
    
    func topAlign(toItem:UIView,
                  multiplier:CGFloat = 1, constant:CGFloat = 0,
                  relatedBy: NSLayoutConstraint.Relation = .equal,
                  addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .top,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .top,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func topAlignWithParent(multiplier:CGFloat = 1, constant:CGFloat = 0) {
        if ( nil != self.superview ) {
            topAlign(toItem: self.superview!, multiplier: multiplier, constant: constant, addConstraintTo: self.superview!);
        }
    }
    
    func bottomFromTopAlign(toItem:UIView,
                     multiplier:CGFloat = 1, constant:CGFloat = 0,
                     relatedBy: NSLayoutConstraint.Relation = .equal,
                     addConstraintTo:UIView? = nil ) {
        
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: relatedBy,
                                              toItem: toItem,
                                              attribute: .top,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func bottomAlign(toItem:UIView,
                     multiplier:CGFloat = 1, constant:CGFloat = 0,
                     relatedBy: NSLayoutConstraint.Relation = .equal,
                     addConstraintTo:UIView? = nil ) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: relatedBy,
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
    func setWidthFromWidth(toItem:UIView, multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil) {
        constrinatHolder(constraintHolder:addConstraintTo, toItem: toItem)?
            .addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: toItem,
                                              attribute: .width,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func setFixedHeight(multiplier:CGFloat = 1, constant:CGFloat = 0, addConstraintTo:UIView? = nil) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func setFixedWidth(multiplier:CGFloat = 1, constant:CGFloat, addConstraintTo:UIView? = nil) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: multiplier,
                                              constant: constant));
    }
    
    func applyBlockElementConstraints(_ parent:UIView? = nil, horizontalMargin:CGFloat = 20) {
        var myParent:UIView? = parent;
        if ( nil == myParent) {
            myParent = self.superview;
        }
        if ( nil == myParent ) {
            return;
        }
        self.centerAlignX(toItem: myParent!);
        self.setWidthFromWidth(toItem: myParent!, constant: (-2) * horizontalMargin);
    }
    
    
    /// Set the desired width of the view
    /// assuming the width of screen in 375 points.
    ///
    /// - Parameter width: desired width of the view
    func setW375Width(width:CGFloat) {
        let windowWidth:CGFloat = 375.0;
        let multiplier = width / windowWidth;
        let window = UIApplication.shared.keyWindow;
        let widthConstant = (window?.frame.width)! * multiplier
            
        self.addConstraint(NSLayoutConstraint(item: self,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: widthConstant));
    }
    
    
    /// Set the desired heigth of the view
    /// assuming the height of screen in 667 points.
    ///
    /// - Parameter height: desired height of the view.
    func setH667Height(height:CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal) {
        let windowHeight:CGFloat = 667.0;
        let multiplier = height / windowHeight;
        let window = UIApplication.shared.keyWindow;
        let heightConstant = (window?.frame.height)! * multiplier

        self.addConstraint(NSLayoutConstraint(item: self,
                                                 attribute: .height,
                                                 relatedBy: relatedBy,
                                                 toItem: nil,
                                                 attribute: .height,
                                                 multiplier: 1,
                                                 constant: heightConstant));
    }
    
    func setAspectRatio(width: CGFloat, height: CGFloat) {
        self.setAspectRatio(widthByHeight: (width/height));
    }
    
    func setAspectRatio(widthByHeight: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .height,
                                              multiplier: widthByHeight,
                                              constant: 0));
    }
    
    
    func getHeightConstant(forHeight height: CGFloat) -> CGFloat {
        let windowHeight: CGFloat = 667.0;
        let multiplier = height / windowHeight;
        let window = UIApplication.shared.keyWindow;
        let heightConstant = (window?.frame.height)! * multiplier
        return heightConstant
    }
}
